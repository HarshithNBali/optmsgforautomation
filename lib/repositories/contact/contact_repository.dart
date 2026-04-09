import 'package:optmsg/core/result.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/repositories/contact/contact_api.dart';
import 'package:optmsg/services/api_service.dart';

/// Repository for Contact-related API calls.
///
/// This encapsulates all contact API logic and provides a clean interface
/// for the ContactListNotifier to use. All methods return `Result<T>` for
/// consistent error handling.
class ContactRepository {
  final ContactApi _contactApi;

  ContactRepository({ContactApi? contactApi})
      : _contactApi = contactApi ?? ContactApi();

  /// Fetches contacts with pagination and search
  Future<Result<ContactListModel>> fetchContacts({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await _contactApi.getContactList({
        "page": page,
        "limit": limit,
        "search": search ?? '',
      });

      if (response.data != null) {
        final contacts = response.data!;
        if (contacts.success) {
          return Result.success(contacts);
        }
        return Result.failure(contacts.message);
      }
      return Result.failure('Failed to fetch contacts');
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while fetching contacts');
    }
  }

  /// Fetches contact details including emails
  Future<Result<Map<String, dynamic>>> fetchContactDetails({
    required int contactId,
  }) async {
    try {
      final response = await _contactApi.getContactDetails({
        "id": contactId,
      });

      if (response.data != null && response.data!['success']) {
        return Result.success(response.data!);
      }
      return Result.failure('Failed to fetch contact details');
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(
          'Something went wrong while fetching contact details');
    }
  }

  /// Deletes a contact by ID
  Future<Result<Map<String, dynamic>>> deleteContact({
    required int contactId,
  }) async {
    try {
      final response = await _contactApi.contactDelete({
        "id": contactId,
      });

      if (response.data != null && response.data!['success']) {
        return Result.success(response.data!);
      }
      return Result.failure(
        response.data?['message'] ?? 'Failed to delete contact',
      );
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while deleting contact');
    }
  }

  /// Adds or removes an email from a contact
  Future<Result<Map<String, dynamic>>> addDeleteEmail({
    required String email,
    required int contactId,
    required String type,
  }) async {
    try {
      final response = await _contactApi.addDeleteEmail({
        "email": email,
        "contactId": contactId,
        "type": type,
      });

      if (response.data != null && response.data!['success']) {
        return Result.success(response.data!);
      }
      return Result.failure(
        response.data?['message'] ?? 'Failed to process email',
      );
    } on NoInternetException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Something went wrong while processing email');
    }
  }
}
