

import '../../model/base_response/request_response.dart';
import '../../model/contact_list_model.dart';
import '../base/base_api_service.dart';
import '../base/refreshable_api.dart';
import '../end_point/end_point.dart';

abstract class ContactService extends RefreshableService {
  ContactService();


  Future<RequestResponse<ContactListModel>> getContactList(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> getContactDetails(Map<String,dynamic> data);

  Future<RequestResponse<Map<String,dynamic>>> contactDelete(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> addDeleteEmail(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> editContact(Map<String,dynamic> data);
  Future<RequestResponse<Map<String,dynamic>>> addContact(Map<String,dynamic> data);





}
class ContactApi extends ContactService{
  ContactApi();

  @override
  Future<RequestResponse<ContactListModel>> getContactList(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getContactList, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: ContactListModel.fromJson(result.data));
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> getContactDetails(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.getContactDetails, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> contactDelete(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.contactDelete, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> addDeleteEmail(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.addDeleteEmail, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(error: result.error);
      }
    });
  }

  @override
  Future<RequestResponse<Map<String,dynamic>>> editContact(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.editContact, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }
  @override
  Future<RequestResponse<Map<String,dynamic>>> addContact(Map<String,dynamic> data) {
    return makeRefreshable(RequestType.post, EndPoints.addContact, body: data,contentType: ContentType.json)
        .then((result) {
      if (result.data != null) {
        return RequestResponse(data: result.data);
      } else {
        return RequestResponse(data: {'success':false,'message':result.error.toString()});
      }
    });
  }

}
