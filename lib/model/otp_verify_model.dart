class OtpVerify {
  OtpVerify({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  OtpVerify.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the model to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `success`: a boolean indicating whether the request was successful
  /// - `data`: a map representing the data in the response
  /// - `message`: a string containing a message from the server
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['data'] = this.data.toJson();
    data['message'] = message;
    return data;
  }
}

class Data {
  Data({
    required this.id,
    this.userName,
    required this.countryCode,
    required this.mobile,
    required this.isVerified,
    required this.type,
    required this.otp,
    required this.validTill,
    required this.created,
    required this.updated,
  });
  late final int id;
  late final Null userName;
  late final String countryCode;
  late final String mobile;
  late final bool isVerified;
  late final String type;
  late final String otp;
  late final int validTill;
  late final String created;
  late final String updated;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = null;
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    isVerified = json['isVerified'];
    type = json['type'];
    otp = json['otp'];
    validTill = json['validTill'];
    created = json['created'];
    updated = json['updated'];
  }

  /// Converts the model to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the user ID
  /// - `userName`: the user name
  /// - `countryCode`: the country code
  /// - `mobile`: the mobile number
  /// - `isVerified`: a boolean indicating whether the user is verified
  /// - `type`: the type of the request
  /// - `otp`: the one-time password
  /// - `validTill`: the valid till timestamp
  /// - `created`: the created timestamp
  /// - `updated`: the updated timestamp
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['userName'] = userName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['isVerified'] = isVerified;
    data['type'] = type;
    data['otp'] = otp;
    data['validTill'] = validTill;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
