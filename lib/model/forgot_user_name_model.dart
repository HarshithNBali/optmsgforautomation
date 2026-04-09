class UserName {
  UserName({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  UserName.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the object to a json-like map.
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
    required this.countryCode,
    required this.mobile,
    required this.type,
    required this.otp,
    required this.validTill,
    required this.updated,
    this.userName,
  });
  late final int id;
  late final String countryCode;
  late final String mobile;
  late final String type;
  late final String otp;
  late final int validTill;
  late final String updated;
  late final String? userName;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    type = json['type'];
    otp = json['otp'];
    validTill = json['validTill'];
    updated = json['updated'];
    userName = json['userName'];
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the user ID
  /// - `countryCode`: the country code
  /// - `mobile`: the mobile number
  /// - `type`: the type of the request
  /// - `otp`: the one-time password
  /// - `validTill`: the valid till timestamp
  /// - `updated`: the updated timestamp
  /// - `userName`: the user name (if available)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['type'] = type;
    data['otp'] = otp;
    data['validTill'] = validTill;
    data['updated'] = updated;
    data['userName'] = userName;
    return data;
  }
}
