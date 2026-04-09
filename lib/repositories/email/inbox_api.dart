import '../../model/base_response/request_response.dart';
import '../../model/inbox_list_model.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class InboxService extends RefreshableService {
  InboxService();


  Future<RequestResponse<InboxListModel>> getInboxEmails(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> updateEmailStatus(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> getEmailTags(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> contactUpload(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> contactUploadToggleContactSync(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> checkEmail(Map<String,dynamic> data);




}
class InboxApi extends InboxService{
  InboxApi();

  @override
  Future<RequestResponse<InboxListModel>> getInboxEmails(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getInboxEmails, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: InboxListModel.fromJson(result.data));
      } else {
        // 401/405: _handleSessionExpiry() already showed "Session expired" toast.
        // Return empty message so getAllEmails() doesn't show a second toast.
        final statusCode = result.error?.statusCode ?? 0;
        final message = (statusCode == 401 || statusCode == 405)
            ? ''
            : result.error?.error ?? '';
        return RequestResponse(data: InboxListModel.fromJson({'success':false,'message':message}));
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> updateEmailStatus(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.updateEmailStatus, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> getEmailTags(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getEmailTags, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> contactUpload(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.contactUpload, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> contactUploadToggleContactSync(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.contactUploadToggleContactSync, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> checkEmail(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.checkEmail, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }



}