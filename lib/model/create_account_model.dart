class CreateAccount {
  CreateAccount({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  CreateAccount.fromJson(Map<String, dynamic> json) {
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
    required this.userName,
    required this.countryCode,
    required this.mobile,
    required this.otp,
    required this.validTill,
    required this.updated,
  });
  late final int id;
  late final String userName;
  late final String countryCode;
  late final String mobile;
  late final String otp;
  late final int validTill;
  late final String updated;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    otp = json['otp'];
    validTill = json['validTill'];
    updated = json['updated'];
  }

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the id
  /// - `userName`: the user name
  /// - `countryCode`: the country code
  /// - `mobile`: the mobile number
  /// - `otp`: the one-time password
  /// - `validTill`: the valid till timestamp
  /// - `updated`: the updated timestamp
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['userName'] = userName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['otp'] = otp;
    data['validTill'] = validTill;
    data['updated'] = updated;
    return data;
  }
}
