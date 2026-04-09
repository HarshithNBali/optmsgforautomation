

import '../../common/utilites/logger.dart';
import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class DraftService extends RefreshableService {
  DraftService();


  Future<RequestResponse<Map<String,dynamic>>> getDraftEmail(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> deleteDraft(Map<String,dynamic> data);




}
class DraftApi extends DraftService{
  DraftApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> getDraftEmail(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getDraftEmail, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error!.error ?? '',});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> deleteDraft(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.deleteDraft, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        printLog("result.data", result.data);
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }


}
