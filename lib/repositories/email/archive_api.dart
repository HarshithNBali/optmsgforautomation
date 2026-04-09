

import '../../common/utilites/logger.dart';
import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class ArchiveService extends RefreshableService {
  ArchiveService();


  Future<RequestResponse<Map<String,dynamic>>> getTrash(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> getSentMails(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> updateEmailStatus(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> permanentlyDeleteDrafts(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> restoreDraft(int draftId);





}
class ArchiveApi extends ArchiveService{
  ArchiveApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> getTrash(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getTrash, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
       // printLog("result.data", result.data);
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error!.error ?? '',});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> getSentMails(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getSentMails, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
       // printLog("result.data", result.data);
        return RequestResponse(data: result.data);
      } else {
        printLog("result.data", result.error?.error ?? '');
        return RequestResponse(data: {'success':false,'message':result.error!.error ?? '',});
      }
    });
  }
  @override
  Future<RequestResponse<Map<String,dynamic>>> updateEmailStatus(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.updateEmailStatus, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        printLog("result.data", result.data);
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> permanentlyDeleteDrafts(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.permanentlyDeleteDrafts, body: data, contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success': false, 'message': result.error?.error ?? ''});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> restoreDraft(int draftId) {
    final endpoint = EndPoint(base: EndPoints.base, path: '${EndPoints.restoreDraftBase}$draftId/restore');
    return makeRefreshable(RequestType.post, endpoint, contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success': false, 'message': result.error?.error ?? ''});
      }
    });
  }
}
