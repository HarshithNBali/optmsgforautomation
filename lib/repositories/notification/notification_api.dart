import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class NotificationService extends RefreshableService {
  NotificationService();


  Future<RequestResponse<Map<String,dynamic>>> getNotification(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> notificationDelete(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> notificationRead(Map<String,dynamic> data);



}
class NotificationApi extends NotificationService{
  NotificationApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> getNotification(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getNotification, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> notificationDelete(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.notificationDelete, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> notificationRead(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.notificationRead, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }




}