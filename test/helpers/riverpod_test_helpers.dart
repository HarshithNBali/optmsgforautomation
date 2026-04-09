/// Riverpod-specific test helpers for creating provider containers with
/// commonly-needed service overrides pre-configured.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../mocks/mock_services.dart';
import '../mocks/mock_repositories.dart';

/// Bundles commonly-needed mock services and provides factory methods for
/// creating pre-configured [ProviderContainer] instances.
class RiverpodTestSetup {
  late final MockApiService mockApiService;
  late final MockSecureStorageService mockStorageService;
  late final MockBiometricService mockBiometricService;
  late final MockAnalyticsService mockAnalyticsService;
  late final MockSocketService mockSocketService;
  late final MockInboxApi mockInboxApi;
  late final MockDraftApi mockDraftApi;
  late final MockTagApi mockTagApi;
  late final MockSettingApi mockSettingApi;
  late final MockArchiveApi mockArchiveApi;
  late final MockAccountApi mockAccountApi;

  RiverpodTestSetup() {
    mockApiService = MockApiService();
    mockStorageService = MockSecureStorageService();
    mockBiometricService = MockBiometricService();
    mockAnalyticsService = MockAnalyticsService();
    mockSocketService = MockSocketService();
    mockInboxApi = MockInboxApi();
    mockDraftApi = MockDraftApi();
    mockTagApi = MockTagApi();
    mockSettingApi = MockSettingApi();
    mockArchiveApi = MockArchiveApi();
    mockAccountApi = MockAccountApi();

    // Apply sensible defaults
    stubStorageDefaults(mockStorageService);
    stubBiometricDefaults(mockBiometricService);
    stubAnalyticsDefaults(mockAnalyticsService);
    stubSocketDefaults(mockSocketService);
  }

  /// Returns the standard set of service + repository provider overrides.
  List<Override> get serviceOverrides => [
        apiServiceProvider.overrideWithValue(mockApiService),
        storageServiceProvider.overrideWithValue(mockStorageService),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
        socketServiceProvider.overrideWithValue(mockSocketService),
        inboxApiProvider.overrideWithValue(mockInboxApi),
        draftApiProvider.overrideWithValue(mockDraftApi),
        tagApiProvider.overrideWithValue(mockTagApi),
        settingApiProvider.overrideWithValue(mockSettingApi),
        archiveApiProvider.overrideWithValue(mockArchiveApi),
        accountApiProvider.overrideWithValue(mockAccountApi),
      ];

  /// Creates a [ProviderContainer] with all core service providers overridden.
  /// Pass additional [overrides] to layer on top.
  ProviderContainer createAuthTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: [
        ...serviceOverrides,
        ...overrides,
      ],
    );
  }
}

/// A simple [ProviderObserver] that records state changes for assertions.
///
/// Usage:
/// ```dart
/// final observer = TestProviderObserver();
/// final container = ProviderContainer(observers: [observer]);
/// // ... trigger state changes ...
/// expect(observer.changes, isNotEmpty);
/// ```
base class TestProviderObserver extends ProviderObserver {
  final List<ProviderStateChange> changes = [];

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    changes.add(ProviderStateChange(
      providerName: context.provider.name ?? context.provider.runtimeType.toString(),
      previousValue: previousValue,
      newValue: newValue,
    ));
  }
}

class ProviderStateChange {
  final String providerName;
  final Object? previousValue;
  final Object? newValue;

  ProviderStateChange({
    required this.providerName,
    required this.previousValue,
    required this.newValue,
  });

  @override
  String toString() =>
      'ProviderStateChange($providerName: $previousValue → $newValue)';
}
