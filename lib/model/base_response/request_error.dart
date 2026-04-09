
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/utilites/logger.dart';

part 'request_error.g.dart';

@JsonSerializable(createToJson: false)
class FieldErrorModel {
  final String? field;
  final String? message;

  FieldErrorModel({this.field, this.message});

  factory FieldErrorModel.fromJson(Map<String, dynamic> json) =>
      _$FieldErrorModelFromJson(json);
}

class RequestError {
  final int? statusCode;

  String? _error;
  List<FieldErrorModel>? _errors;

  String? get error => _error;
  List<FieldErrorModel>? get errors => _errors;

  RequestError({this.statusCode, data}) {
    if (data != null) {
      printLog(" error data", jsonEncode(data));

      // ✅ FIX: handle String message directly
      if (data is Map && data['message'] is String) {
        _error = data['message'];
        return;
      }

      if (jsonEncode(data).contains("errors") ||
          jsonEncode(data).contains("detail") ||
          jsonEncode(data).contains("match_format") ||
          jsonEncode(data).contains("error") ||
          jsonEncode(data).contains("message")) {

        if (data['errors'] != null) {
          _parseError(data);
        }
        else if (data['detail'] != null) {
          _error = data['detail'];
        }
        else if (data['match_format'] != null) {
          _error = data['match_format'][0];
        }
        else if (data['error'] != null) {
          _error = data['error'];
        }
        // ✅ FIX: message can be String OR List
        else if (data['message'] != null) {
          if (data['message'] is String) {
            _error = data['message'];
          } else {
            _parseError(data);
          }
        }
        else {
          _parseError(data);
        }
      }
      else {
        _error = data[0];
      }
    }
  }

  factory RequestError.singleMessage(String message) {
    final e = RequestError();
    e._error = message;
    printLog("message", e._error);
    return e;
  }

  factory RequestError.noUser() {
    return RequestError().._error = "No User";
  }

  factory RequestError.noToken() {
    return RequestError().._error = "Empty Token";
  }

  // ✅ FIX: protect against message being String
  void _parseError(Map d) {
    printLog("map Data", d);

    if (d['errors'] != null && d['errors'] is List) {
      _errors = List<FieldErrorModel>.from(
        d['errors'].map((e) => FieldErrorModel.fromJson(e)),
      );
    }
    else if (d['message'] != null && d['message'] is List) {
      _errors = List<FieldErrorModel>.from(
        d['message'].map((e) => FieldErrorModel.fromJson(e)),
      );
    }
  }
}
