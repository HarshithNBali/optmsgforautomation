import 'dart:async';

import 'package:descope/descope.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import '../main.dart';
import 'count_notifier.dart';
import 'session_refresh_mutex.dart';


class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  sio.Socket? _socket;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isRetryingAuth = false;
  int _userId = 0;

  final Map<String, StreamController<dynamic>> _eventStreams = {};

  Future<void> initSocket(String url, String? token, int userId) async {
    if (_isInitialized) return;
    _isInitialized = true;
    _isDisposed = false;
    _userId = userId;

    // H-12: Clean up any existing socket before reinitialising.
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    // Bug 4: Do NOT clear _eventStreams here — active StreamSubscriptions in
    // notifiers (inbox, archive, trash) point to these controllers. Clearing
    // them orphans subscriptions so socket events are silently dropped after
    // reconnect. Streams are cleaned up properly in disconnect() on full
    // session teardown.

    _socket = sio.io(url, {
      'autoConnect': true,
      'transports': ['websocket'],
      'forceNew': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
    });

    _socket!.onAny((event, data) {
      if (kDebugMode) {
        // M-14: Redact events that carry tokens, user IDs, or PII
        const sensitiveEvents = {
          'login',
          'newMessage',
          'paymentStatus',
          'addCardSuccess',
          'inboxMessage',
          'msgOptInApp',
        };
        if (sensitiveEvents.contains(event)) {
          debugPrint("📡 $event => [REDACTED]");
        } else {
          debugPrint("📡 $event => $data");
        }
      }
    });

    _socket!
      ..onConnect((_) {
        if (kDebugMode) debugPrint("✅ Socket connected");
        if (firebaseReady && !kIsWeb) FirebaseCrashlytics.instance.log('socket: connected');
        // H-13: Always use the freshest available JWT rather than the stale closure value
        final freshToken = Descope.sessionManager.session?.sessionJwt ?? token ?? '';
        emitEventWithAck('login', {"token": freshToken, "tokentype": 'descope'});
        emitEventWithAck('notificationExists', {"userId": userId});
        emitEventWithAck('unReadCount', {"userId": userId});
      })
      ..onDisconnect((_) {
        if (kDebugMode) debugPrint("❌ Socket disconnected");
        if (firebaseReady && !kIsWeb) FirebaseCrashlytics.instance.log('socket: disconnected');
        _isInitialized = false;
        _isRetryingAuth = false;
        _emitToStream('socketDisconnect', null);
      })
      ..onReconnect((_) {
        if (kDebugMode) debugPrint("🔁 Socket reconnected");
        // H-13: Use a fresh token on reconnect — the original may have expired
        final freshToken = Descope.sessionManager.session?.sessionJwt ?? token ?? '';
        emitEventWithAck('login', {"token": freshToken, "tokentype": 'descope'});
        emitEventWithAck('unReadCount', {"userId": userId});
        emitEventWithAck('notificationExists', {"userId": userId});
      })
      ..on('connect_error', (data) {
        if (kDebugMode) debugPrint("⚠️ Socket connect_error: $data");
        if (firebaseReady && !kIsWeb) {
          FirebaseCrashlytics.instance.log('socket: connect_error: ${_sanitizeForLog(data)}');
        }
        _emitToStream('socketError', data);
        // Bug 4: Removed _refreshAndRetryLogin() call — the built-in
        // reconnection handler (onReconnect) already re-authenticates with
        // a fresh JWT. Calling refresh here caused auth state churn.
      })
      ..on('error', (data) {
        if (kDebugMode) debugPrint("⚠️ Socket error: $data");
        if (firebaseReady && !kIsWeb) {
          FirebaseCrashlytics.instance.log('socket: error: ${_sanitizeForLog(data)}');
        }
        _emitToStream('socketError', data);
      });

    /// ⭐ IMPORTANT — unread count event
    _socket!.on('unReadCount', (data) {
      _emitToStream('unReadCount', data);
      _updateCountNotifier(data);
    });

    _socket!.on('addCardSuccess', (d) => _emitToStream('addCardSuccess', d));
    _socket!.on('newMessage', (d) {
      _emitToStream('newMessage', d);
      emitEventWithAck('unReadCount', {"userId": userId});
    });

    _socket!.on('notificationExists', (d) => _emitToStream('notificationExists', d));
    _socket!.on('trashMessage', (d) => _emitToStream('trashMessage', d));
    _socket!.on('inboxMessage', (d) => _emitToStream('inboxMessage', d));
    _socket!.on('msgOptInApp', (d) => _emitToStream('msgOptInApp', d));
    _socket!.on('paymentStatus', (d) => _emitToStream('paymentStatus', d));
    _socket!.on('tagList', (d) => _emitToStream('tagList', d));
  }

  /// SAFE EMIT
  void emitEventWithAck(
      String event,
      Map<String, dynamic> data, {
        Function(dynamic)? ackCallback,
      }) {
    if (_socket == null) return;

    if (!_socket!.connected) {
      _socket!.connect();
      return;
    }

    _socket!.emitWithAck(event, data, ack: (response) {
      // H-17: Guard against callbacks arriving after disconnect
      if (_isDisposed) return;
      if (kDebugMode) debugPrint("✅ ACK [$event] => $response");

      // If the server rejected our login with "Invalid Token", try refreshing
      // the JWT and re-sending rather than letting the session expire.
      if (event == 'login' && response is Map) {
        final success = response['success'];
        final message = response['message']?.toString() ?? '';
        if (success == false || message.contains('Invalid Token')) {
          _refreshAndRetryLogin();
          return;
        }
      }

      if (ackCallback != null) ackCallback(response);

      /// ⭐ ACK unread count update
      if (event == 'unReadCount' && response != null) {
        _updateCountNotifier(response);
      }

      /// ⭐ ACK notification status update
      if (event == 'notificationExists' && response != null) {
        _updateNotificationStatus(response);
      }
    });
  }

  /// ⭐ COUNT NOTIFIER UPDATE
  void _updateCountNotifier(dynamic response) {
    if (response == null || _isDisposed) return;

    try {
      providerContainer.read(countProvider.notifier).updateCounts(
        inbox: (response['inboxCount'] as num?)?.toInt() ?? 0,
        draft: (response['draftCount'] as num?)?.toInt() ?? 0,
        archive: (response['archiveCount'] as num?)?.toInt() ?? 0,
        trash: (response['trashCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint("CountNotifier update error $e");
    }
  }

  /// ⭐ NOTIFICATION STATUS UPDATE
  void _updateNotificationStatus(dynamic data) {
    if (data == null || _isDisposed) return;
    try {
      providerContainer
          .read(countProvider.notifier)
          .updateNotificationStatus(data.toString());
    } catch (e) {
      debugPrint("NotificationStatus update error $e");
    }
  }

  Stream<dynamic> onEvent(String event) {
    _eventStreams.putIfAbsent(event, () => StreamController.broadcast());
    return _eventStreams[event]!.stream;
  }

  void _emitToStream(String event, dynamic data) {
    final controller = _eventStreams[event];
    if (controller != null && !controller.isClosed) {
      controller.add(data);
    }
  }

  /// Attempts to refresh the Descope JWT and re-send the socket login event.
  /// Called when the server rejects a stale token (connect_error or login ACK
  /// with "Invalid Token"). Guarded to prevent re-entrant retry loops.
  Future<void> _refreshAndRetryLogin() async {
    if (_isRetryingAuth || SessionRefreshMutex.isLoggedOut) return;
    _isRetryingAuth = true;
    try {
      await SessionRefreshMutex.guardedRefreshIfNeeded();
      final freshToken = Descope.sessionManager.session?.sessionJwt;
      if (freshToken != null && freshToken.isNotEmpty) {
        emitEventWithAck('login', {"token": freshToken, "tokentype": 'descope'});
        emitEventWithAck('unReadCount', {"userId": _userId});
        emitEventWithAck('notificationExists', {"userId": _userId});
      }
    } catch (e) {
      debugPrint('[Socket] JWT refresh for retry failed: $e');
      // Don't force logout — let existing API/timer expiry flows handle it
    } finally {
      _isRetryingAuth = false;
    }
  }

  void disconnect() {
    _isDisposed = true;
    _isRetryingAuth = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isInitialized = false;

    for (final c in _eventStreams.values) {
      c.close();
    }
    _eventStreams.clear();
  }

  /// H-SEC-04: Sanitize socket error payloads before sending to Crashlytics.
  /// Strips tokens, truncates to prevent large payloads leaking PII.
  static String _sanitizeForLog(dynamic data) {
    if (data == null) return 'null';
    final raw = data.toString();
    // Strip anything that looks like a JWT or token value
    final sanitized = raw.replaceAll(
      RegExp(r'eyJ[A-Za-z0-9_-]{10,}'),
      '[REDACTED_TOKEN]',
    );
    // Truncate to 200 chars to limit PII exposure
    return sanitized.length > 200 ? '${sanitized.substring(0, 200)}…' : sanitized;
  }

  bool isConnected() => _socket?.connected ?? false;

  /// Call on app resume: if the socket object exists but lost its connection
  /// (e.g. auto-reconnect exhausted while backgrounded), force a reconnect.
  void reconnectIfNeeded() {
    if (_socket != null && !_socket!.connected) {
      _socket!.connect();
    }
  }
}