import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class AccountService extends RefreshableService {
  AccountService();

  Future<RequestResponse<Map<String, dynamic>>> deleteAccount(
    Map<String, dynamic> data,
  );
  Future<RequestResponse<Map<String, dynamic>>> paymentList(
    Map<String, dynamic> data,
  );

  Future<RequestResponse<Map<String, dynamic>>> getProfile(
    Map<String, dynamic> data,
  );
  Future<RequestResponse<Map<String, dynamic>>> editProfile(
    Map<String, dynamic> data,
  );
}

class AccountApi extends AccountService {
  AccountApi();

  /// ✅ Common response mapper
  RequestResponse<Map<String, dynamic>> _mapResult(
    RequestResponse<dynamic> result,
  ) {
    final data = result.data; // <- single access

    if (data != null) {
      return RequestResponse(data: data);
    } else {
      return RequestResponse(
        data: {'success': false, 'message': result.error.toString()},
      );
    }
  }

  @override
  Future<RequestResponse<Map<String, dynamic>>> deleteAccount(
    Map<String, dynamic> data,
  ) {
    return makeRefreshable(
      RequestType.delete,
      EndPoints.deleteAccount,
      body: data,
      contentType: ContentType.json,
    ).then(_mapResult);
  }

  @override
  Future<RequestResponse<Map<String, dynamic>>> paymentList(
    Map<String, dynamic> data,
  ) {
    return makeRefreshable(
      RequestType.post,
      EndPoints.paymentList,
      body: data,
      contentType: ContentType.json,
    ).then(_mapResult);
  }

  @override
  Future<RequestResponse<Map<String, dynamic>>> getProfile(
    Map<String, dynamic> data,
  ) {
    return makeRefreshable(
      RequestType.get,
      EndPoints.getProfile,
      body: data,
      contentType: ContentType.json,
    ).then(_mapResult);
  }

  @override
  Future<RequestResponse<Map<String, dynamic>>> editProfile(
    Map<String, dynamic> data,
  ) {
    return makeRefreshable(
      RequestType.post,
      EndPoints.editProfile,
      body: data,
      contentType: ContentType.json,
    ).then(_mapResult);
  }
}
