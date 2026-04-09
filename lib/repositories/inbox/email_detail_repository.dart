import 'package:optmsg/core/result.dart';
import 'package:optmsg/model/view_email_model.dart';
import 'package:optmsg/services/api_service.dart';

/// Repository for email detail-related API calls.
///
/// This encapsulates all email detail API logic and provides a clean interface
/// for the EmailDetailNotifier to use. All methods return `Result<T>` for
/// consistent error handling.
class EmailDetailRepository {
  final ApiService _apiService;

  EmailDetailRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches email detail by ID
  Future<Result<ViewEmailModel>> fetchEmailDetail({
    required int emailId,
  }) async {
    try {
      final response = await _apiService.post(
        'email/view-email',
        {'emailId': emailId},
      );

      if (response['success'] == true) {
        final emailData = ViewEmailModel.fromJson(response);
        return Result.success(emailData);
      } else {
        return Result.failure(
          response['message'] ?? 'Failed to load email',
        );
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while loading email');
    }
  }

  /// Updates email status (read, archive, trash, etc.)
  Future<Result<Map<String, dynamic>>> updateEmailStatus({
    required String key,
    required List<int> emailIds,
    required bool value,
  }) async {
    try {
      final response = await _apiService.post(
        'email/update-email-status',
        {
          'key': key,
          'emailIds': emailIds,
          'value': value,
        },
      );

      if (response['success'] == true) {
        return Result.success(response);
      } else {
        return Result.failure(
          response['message'] ?? 'Failed to update email status',
        );
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while updating email');
    }
  }

  /// Adds or removes tags from an email
  Future<Result<Map<String, dynamic>>> manageEmailTags({
    required List<int> emailIds,
    required List<int> tagIds,
    required String type, // 'add' or 'delete'
  }) async {
    try {
      final response = await _apiService.post(
        'email/emails-tags',
        {
          'emailIds': emailIds,
          'tagsId': tagIds,
          'type': type,
        },
      );

      if (response['success'] == true) {
        return Result.success(response);
      } else {
        return Result.failure(
          response['message'] ?? 'Failed to manage tags',
        );
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while managing tags');
    }
  }

  /// Permanently deletes an email
  Future<Result<Map<String, dynamic>>> permanentlyDeleteEmail({
    required int emailId,
  }) async {
    try {
      final response = await _apiService.post(
        'email/delete-email',
        {
          'emailIds': [emailId]
        },
      );

      if (response['success'] == true) {
        return Result.success(response);
      } else {
        return Result.failure(
          response['message'] ?? 'Failed to delete email',
        );
      }
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while deleting email');
    }
  }
}
