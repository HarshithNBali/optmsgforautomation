import 'package:optmsg/core/result.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/repositories/email/inbox_api.dart';
import 'package:optmsg/repositories/tags/tag_api.dart';
import 'package:optmsg/services/api_service.dart';

/// Repository for inbox-related API calls.
///
/// This encapsulates all inbox API logic and provides a clean interface
/// for the InboxNotifier to use. All methods return `Result<T>` for
/// consistent error handling.
class InboxRepository {
  final InboxApi _inboxApi;
  final TagApi _tagApi;

  InboxRepository({
    InboxApi? inboxApi,
    TagApi? tagApi,
  })  : _inboxApi = inboxApi ?? InboxApi(),
        _tagApi = tagApi ?? TagApi();

  /// Fetches inbox emails with pagination and filtering
  Future<Result<InboxListModel>> fetchEmails({
    required String type,
    required int page,
    required int limit,
    String? search,
    List<int>? tagIds,
  }) async {
    try {
      final reqData = <String, dynamic>{
        'type': type,
        'page': page,
        'limit': limit,
        'search': search ?? '',
      };

      if (tagIds != null && tagIds.isNotEmpty) {
        reqData['tagsId'] = tagIds;
      }

      final response = await _inboxApi.getInboxEmails(reqData);

      if (response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.failure('Failed to fetch emails');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while fetching emails');
    }
  }

  /// Updates email status (read, archive, trash, etc.)
  Future<Result<Map<String, dynamic>>> updateEmailStatus({
    required String key,
    required List<int> emailIds,
    required bool value,
  }) async {
    try {
      final response = await _inboxApi.updateEmailStatus({
        'key': key,
        'emailIds': emailIds,
        'value': value,
      });

      if (response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.failure('Failed to update email status');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while updating email');
    }
  }

  /// Adds or removes tags from emails
  Future<Result<Map<String, dynamic>>> manageEmailTags({
    required List<int> emailIds,
    required List<int> tagIds,
    required String type, // 'add' or 'delete'
  }) async {
    try {
      final response = await _inboxApi.getEmailTags({
        'emailIds': emailIds,
        'tagsId': tagIds,
        'type': type,
      });

      if (response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.failure('Failed to manage tags');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while managing tags');
    }
  }

  /// Fetches all tags
  Future<Result<TagsListModel>> fetchTags({String search = ''}) async {
    try {
      final response = await _tagApi.getTagsList({'search': search});

      if (response.data != null) {
        final tagsList = TagsListModel.fromJson(response.data!);
        if (tagsList.success) {
          return Result.success(tagsList);
        } else {
          return Result.failure(tagsList.message);
        }
      } else {
        return Result.failure('Failed to fetch tags');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while fetching tags');
    }
  }

  /// Permanently deletes emails
  Future<Result<Map<String, dynamic>>> permanentlyDeleteEmails({
    required List<int> emailIds,
  }) async {
    try {
      final response = await ApiService().post(
        'email/delete-email',
        {'emailIds': emailIds},
      );

      if (response['success'] == true) {
        return Result.success(response);
      } else {
        return Result.failure(response['message'] ?? 'Failed to delete emails');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while deleting emails');
    }
  }

  /// Restores emails from trash or archive
  Future<Result<Map<String, dynamic>>> restoreEmails({
    required List<int> emailIds,
    required String restoreType, // 'isInbox' or 'isSent'
  }) async {
    try {
      final response = await ApiService().post(
        'email/undo-email',
        {
          'emailIds': emailIds,
          'type': restoreType,
        },
      );

      if (response['success'] == true) {
        return Result.success(response);
      } else {
        return Result.failure(
            response['message'] ?? 'Failed to restore emails');
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while restoring emails');
    }
  }
}
