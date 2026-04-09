import '../../model/base_response/request_response.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class TagService extends RefreshableService {
  TagService();


  Future<RequestResponse<Map<String,dynamic>>> getTagsList(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> addTags(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> editTag(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> deleteTag(Map<String,dynamic> data);



}
class TagApi extends TagService{
  TagApi();

  @override
  Future<RequestResponse<Map<String,dynamic>>> getTagsList(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getTagsList, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> addTags(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.addTags, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> editTag(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.editTag, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> deleteTag(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.deleteTag, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }


}
