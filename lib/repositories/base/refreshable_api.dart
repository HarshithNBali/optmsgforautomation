import 'package:optmsg/services/common_service.dart';
import 'package:descope/descope.dart';
import '../../../model/base_response/request_response.dart';
import '../end_point/end_point.dart';
import 'base_api_service.dart';
import '../../../services/api_service.dart' show CancelToken;

class RefreshableService extends BaseAPIService {
  RefreshableService();

  Future<RequestResponse<dynamic>> makeRefreshable(
      RequestType type, EndPoint endpoint,
      {dynamic body,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      String? contentType,
      CancelToken? cancelToken,
      Duration timeout = const Duration(seconds: 30)}) async {
    // PH-01: Removed duplicate guardedRefreshIfNeeded() that was here.
    // make() already handles JWT refresh, session recovery (loadSession),
    // and terminal expiry via SessionExpiryManager — calling it here too
    // just added latency behind the refresh mutex for no benefit.

    String version = await CommonService().getAppVersion();
    Map<String, dynamic> allHeaders = {
      "accept": "application/json",
      "x-opt-platform": CommonService().getPlatform(),
      "accept-language": "en",
      'x-opt-version': version,
      "Content-Type": "application/json",
    };

    if (Descope.sessionManager.session != null) {
      allHeaders.addAll({
        'authorization': Descope.sessionManager.session!.sessionJwt,
        'tokentype': 'descope'
      });
    }
    if (headers != null && headers.isNotEmpty) {
      allHeaders.addAll(headers);
    }
    return make(type, endpoint,
            body: body,
            headers: allHeaders,
            params: params,
            cancelToken: cancelToken,
            timeout: timeout)
        .then((value) {
      if (value.data != null) {
        return RequestResponse(data: value.data);
      } else {
        return RequestResponse(error: value.error);
      }
    });
  }

}
