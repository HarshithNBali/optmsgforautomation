import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class SettingService extends RefreshableService {
  SettingService();


  Future<RequestResponse<Map<String,dynamic>>> deviceBiometric(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> logout(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> toggleNotification(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> contactSortToggle(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> toggleContactSynch(Map<String,dynamic> data);



}
class SettingApi extends SettingService{
  SettingApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> deviceBiometric(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.deviceBiometric, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> logout(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.get, EndPoints.logout, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> toggleNotification(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.toggleNotification, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> contactSortToggle(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.contactSortToggle, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> toggleContactSynch(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.toggleContactSynch, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }



}