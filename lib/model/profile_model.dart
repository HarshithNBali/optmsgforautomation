class MyProfile {
  MyProfile({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  MyProfile.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `MyProfile` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `success`: a boolean indicating whether the request was successful
  /// - `data`: a map representing the user's profile data, as returned by `Data.toJson()`
  /// - `message`: a string containing a message

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
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.otp,
    required this.dob,
    required this.countryCode,
    required this.mobile,
    required this.isSubscribed,
    this.deviceToken,
    this.authTokenIssuedAt,
    this.platform,
    required this.isNotification,
    required this.isAcceptTerms,
    required this.isSuspended,
    required this.isDeleted,
    required this.created,
    required this.updated,
    required this.isDeviceBiometrics,
    required this.isBiomatrix,
  });
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String userName;
  late final String? otp;
  late final String dob;
  late final String countryCode;
  late final String mobile;
  late final bool isSubscribed;
  late final String? deviceToken;
  late final int? authTokenIssuedAt;
  late final Null platform;
  late final bool isNotification;
  late final bool isAcceptTerms;
  late final bool isSuspended;
  late final bool isDeleted;
  late final String created;
  late final String updated;
  late final bool isDeviceBiometrics;
  late final bool isBiomatrix;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
    otp = json['otp'];
    dob = json['dob'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    isSubscribed = json['isSubscribed'];
    deviceToken = json['deviceToken'];
    authTokenIssuedAt = json['authTokenIssuedAt'];
    platform = null;
    isNotification = json['isNotification'];
    isAcceptTerms = json['isAcceptTerms'];
    isSuspended = json['isSuspended'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
    isBiomatrix = json['isBiomatrix'];
    isDeviceBiometrics = json['isDeviceBiometrics'];
  }

  /// Converts the model to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the user ID
  /// - `firstName`: the user first name
  /// - `lastName`: the user last name
  /// - `userName`: the user name
  /// - `otp`: the one-time password (if available)
  /// - `dob`: the date of birth
  /// - `countryCode`: the country code
  /// - `mobile`: the mobile number
  /// - `isSubscribed`: a boolean indicating whether the user is subscribed
  /// - `deviceToken`: the device token
  /// - `authTokenIssuedAt`: the auth token issued at timestamp
  /// - `platform`: the platform
  /// - `isNotification`: a boolean indicating whether the user has notifications
  /// - `isAcceptTerms`: a boolean indicating whether the user has accepted terms
  /// - `isSuspended`: a boolean indicating whether the user is suspended
  /// - `isDeleted`: a boolean indicating whether the user is deleted
  /// - `created`: the created timestamp
  /// - `updated`: the updated timestamp
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['userName'] = userName;
    if (otp != null) {
      data['otp'] = otp;
    }
    data['dob'] = dob;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['isSubscribed'] = isSubscribed;
    data['deviceToken'] = deviceToken;
    data['authTokenIssuedAt'] = authTokenIssuedAt;
    data['platform'] = platform;
    data['isNotification'] = isNotification;
    data['isAcceptTerms'] = isAcceptTerms;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    data['isDeviceBiometrics'] = isDeviceBiometrics;
    data['isBiomatrix'] = isBiomatrix;
    return data;
  }
}
