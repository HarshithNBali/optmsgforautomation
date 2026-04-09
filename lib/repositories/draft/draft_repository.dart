import 'package:optmsg/core/result.dart';
import 'package:optmsg/model/draft_list_modal.dart';
import 'package:optmsg/repositories/email/draft_api.dart';
import 'package:optmsg/services/api_service.dart';

/// Repository for Draft-related API calls.
///
/// This encapsulates all draft API logic and provides a clean interface
/// for the DraftNotifier to use. All methods return `Result<T>` for
/// consistent error handling.
class DraftRepository {
  final DraftApi _draftApi;

  DraftRepository({DraftApi? draftApi}) : _draftApi = draftApi ?? DraftApi();

  /// Fetches draft emails with pagination and search
  Future<Result<DraftListModel>> fetchDrafts({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await _draftApi.getDraftEmail({
        "page": page,
        "limit": limit,
        "search": search ?? '',
      });

      if (response.data != null) {
        final draftList = DraftListModel.fromJson(response.data!);
        if (draftList.success) {
          return Result.success(draftList);
        }
        return Result.failure(draftList.message);
      }
      return Result.failure('Failed to fetch drafts');
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while fetching drafts');
    }
  }

  /// Deletes draft emails by their IDs
  Future<Result<Map<String, dynamic>>> deleteDrafts({
    required List<int> draftIds,
  }) async {
    try {
      final response = await _draftApi.deleteDraft({
        "draftIds": draftIds,
      });

      if (response.data != null && response.data!['success']) {
        return Result.success(response.data!);
      }
      return Result.failure(
        response.data?['message'] ?? 'Failed to delete drafts',
      );
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while deleting drafts');
    }
  }
}
