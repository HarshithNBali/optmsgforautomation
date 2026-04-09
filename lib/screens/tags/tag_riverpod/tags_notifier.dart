import 'dart:async';

import 'package:optmsg/repositories/tags/tag_api.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/tags_list_model.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
final tagsProvider = NotifierProvider<TagsNotifier, TagsState>(
  TagsNotifier.new,
);

class TagsNotifier extends Notifier<TagsState> {
  StreamSubscription? _tagsSub;
  bool _disposed = false;
  Map<String, dynamic> userData = {};
  String token = '';
  int? _currentUserId; // Track current user ID to detect account switches
  // M-17: serialise mutating operations so rapid taps can't create duplicates
  bool _isOperationInProgress = false;
  late final SecureStorageService secureStorageService;
  late final TagApi _tagApi;

  @override
  TagsState build() {
    secureStorageService = ref.read(storageServiceProvider);
    _tagApi = ref.read(tagApiProvider);
    // Reset mutable session fields on each build so stale data isn't carried
    // across logout/re-login cycles
    _disposed = false;
    userData = {};
    token = '';
    _currentUserId = null;
    ref.onDispose(() {
      _disposed = true;
      _tagsSub?.cancel();
    });
    Future.microtask(_init);
    return const TagsState();
  }

  /// Initialize notifier
  Future<void> _init() async {
    await getUserData();
    if (_disposed) return;
    _setupListeners();
    manageComposeFlag();
    _currentUserId = userData['user']?['id'];
    getAllTags();
  }

  /// Load user data
  Future<void> getUserData() async {
    try {
      final data = ref.read(authProvider).userData;
      if (data != null) {
        userData = data;
        token = userData['token'];
      } else {
        userData = {};
      }
    } catch (_) {
      userData = {};
    }
  }

  /// Check if user has changed and refresh tags if needed
  /// This should be called when the tags page becomes active
  Future<void> checkAndRefreshIfUserChanged() async {
    try {
      await getUserData();
      if (_disposed) return;
      final newUserId = userData['user']?['id'];

      // If user ID has changed, reset state and reload tags
      if (_currentUserId != null && _currentUserId != newUserId) {
        _currentUserId = newUserId;
        state = const TagsState();
        if (_disposed) return;
        await getAllTags();
      } else if (_currentUserId == null) {
        // First time loading, set user ID
        _currentUserId = newUserId;
        // If tags are empty, fetch them
        if (state.tagsList == null || state.tagsList!.data.tags.isEmpty) {
          await getAllTags();
        }
      } else {
        // Same user, but ensure tags are loaded
        if (state.tagsList == null || state.tagsList!.data.tags.isEmpty) {
          await getAllTags();
        }
      }
    } catch (_) {}
  }

  /// Socket listener init
  void _setupListeners() {
    _tagsSub = SocketService().onEvent('tagList').listen((data) {
      if (_disposed) return;
      if (data is List) {
        final wrappedData = {
          'success': true,
          'message': 'Tags from socket',
          'data': {'tags': data},
        };

        final parsed = TagsListModel.fromJson(wrappedData);

        state = state.copyWith(tagsList: parsed, isLoading: false);
      }
    });
  }

  dynamic manageComposeFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('inCompose', false);
  }

  /// =============================
  /// CRUD OPERATIONS
  /// =============================

  void setTagsList(TagsListModel model) {
    state = state.copyWith(tagsList: model, isLoading: false);
  }

  void setEditFlag(bool value) {
    state = state.copyWith(editFlag: value);
  }

  void setId(int value) {
    state = state.copyWith(id: value);
  }

  Future<void> getAllTags({bool isRefresh = false}) async {
    if (!isRefresh) {
      state = state.copyWith(isLoading: true);
    }

    try {
      final res = await _tagApi.getTagsList({"search": ""});
      if (_disposed) return;

      final parsed = TagsListModel.fromJson(res.data!);

      if (parsed.success) {
        setTagsList(parsed);
      } else {
        CommonService.animatedToast(parsed.message, 'error', null, true);
      }
    } catch (e) {
      if (_disposed) return;
      if (e is! NoInternetException) {
        // Prevent crash on other exceptions (like 405)
        // CommonService.animatedToast(e.toString(), 'error', null, true);
      }
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addTag(String tag) async {
    if (_isOperationInProgress) return;
    _isOperationInProgress = true;
    try {
      final res = await _tagApi.addTags({"tag": tag});
      if (_disposed || res.data == null) return;

      CommonService.animatedToast(
        res.data!['message'],
        res.data!['success'] ? 'success' : 'error',
        null,
        true,
      );

      if (res.data!['success']) {
        await getAllTags();
      }
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(e.toString(), 'error', null, true);
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  Future<void> editTag(int id, String tag) async {
    if (_isOperationInProgress) return;
    _isOperationInProgress = true;
    try {
      final res = await _tagApi.editTag({"id": id, "tag": tag});
      if (_disposed || res.data == null) return;

      CommonService.animatedToast(
        res.data!['message'],
        res.data!['success'] ? 'success' : 'error',
        null,
        true,
      );

      if (res.data!['success']) {
        await getAllTags();
      }
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(e.toString(), 'error', null, true);
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  Future<void> deleteTag(int id) async {
    if (_isOperationInProgress) return;
    _isOperationInProgress = true;
    try {
      final res = await _tagApi.deleteTag({"id": id});
      if (_disposed || res.data == null) return;

      CommonService.animatedToast(
        res.data!['message'],
        res.data!['success'] ? 'success' : 'error',
        null,
        true,
      );

      if (res.data!['success']) {
        await getAllTags();
        // Purge of deleted tag from inbox/archive email items happens
        // automatically via ref.listen(tagsProvider) in those notifiers.
      }
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(e.toString(), 'error', null, true);
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  // =============================
  // MULTI-SELECT
  // =============================

  void setShowCheckboxes(bool v) {
    state = state.copyWith(showCheckboxes: v);
  }

  void toggleSelectTag(int id) {
    final ids = [...state.selectedTagIds];
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(
      selectedTagIds: ids,
      allTagsFlag: ids.length == state.tags.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  void selectAllTags() {
    final ids = state.tags.map((t) => t.id).toList();
    state = state.copyWith(
      selectedTagIds: ids,
      allTagsFlag: true,
      longPressFlag: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedTagIds: <int>[],
      allTagsFlag: false,
      longPressFlag: true,
      showCheckboxes: false,
      lastClickedIndex: -1,
    );
  }

  void selectRangeFromList(int fromIndex, int toIndex) {
    final tags = state.tags;
    if (tags.isEmpty) return;
    final start = fromIndex.clamp(0, tags.length - 1);
    final end = toIndex.clamp(0, tags.length - 1);
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;

    final ids = {...state.selectedTagIds};
    for (int i = lo; i <= hi; i++) {
      ids.add(tags[i].id);
    }

    state = state.copyWith(
      selectedTagIds: ids.toList(),
      allTagsFlag: ids.length == tags.length,
      longPressFlag: false,
      showCheckboxes: true,
      lastClickedIndex: toIndex.clamp(0, tags.length - 1),
    );
  }

  void toggleSingleSelectByIndex(int index) {
    final tags = state.tags;
    if (index < 0 || index >= tags.length) return;
    final id = tags[index].id;
    final ids = [...state.selectedTagIds];

    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }

    state = state.copyWith(
      selectedTagIds: ids,
      allTagsFlag: ids.length == tags.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.length > 1 ? true : state.showCheckboxes,
      lastClickedIndex: index,
    );
  }

  void setSelectedFromList(List<int> ids) {
    state = state.copyWith(
      selectedTagIds: ids,
      allTagsFlag: ids.length == state.tags.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  Future<void> deleteSelectedTags() async {
    final idsToDelete = [...state.selectedTagIds];
    clearSelection();
    for (final id in idsToDelete) {
      await deleteTag(id);
      if (_disposed) return;
    }
  }

  /// Reset tags state to initial state (used during logout)
  void reset() {
    _tagsSub?.cancel();
    state = const TagsState();
    userData = {};
    token = '';
    _currentUserId = null;
  }
}
