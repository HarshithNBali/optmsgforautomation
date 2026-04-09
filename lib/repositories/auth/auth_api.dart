
import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class AuthService extends RefreshableService {
  AuthService();


  Future<RequestResponse<Map<String,dynamic>>> userVerify(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> userLogin(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> resenOTP(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> verifyOTP(Map<String,dynamic> data);



}
class AuthApi extends AuthService{
  AuthApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> userVerify(Map<String,dynamic> data) {
    return make(RequestType.post, EndPoints.userVerify, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {

        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> userLogin(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.login, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {

        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> resenOTP(Map<String,dynamic> data) {
    return make(RequestType.post, EndPoints.resenOTP, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {

        return RequestResponse(error: result.error);
      }
    });
  }
  @override
  Future<RequestResponse<Map<String,dynamic>>> verifyOTP(Map<String,dynamic> data) {
    return make(RequestType.post, EndPoints.verifyOTP, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {

        return RequestResponse(error: result.error);
      }
    });
  }


}
