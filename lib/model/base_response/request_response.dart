import 'package:optmsg/model/base_response/request_error.dart';

class RequestResponse<T> {
  final T? data;
  final RequestError? error;

  RequestResponse({this.data, this.error});
}
