import 'package:optmsg/model/subscription_status.dart';

class LoginModel {
  LoginModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    data = Data.fromJson(json['data'] ?? {});
    message = json['message'] ?? '';
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
    required this.user,
    required this.token,
  });
  late final User user;
  late final String token;

  Data.fromJson(Map<String, dynamic> json) {
    user = User.fromJson(
      (json['user'] as Map<String, dynamic>?) ?? {},
    );

    token = (json['token'] as String?) ?? '';
  }

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `user`: a map representing the user, as returned by `User.toJson()`
  /// - `token`: the authentication token
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user'] = user.toJson();
    data['token'] = token;
    return data;
  }
}

class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.otp,
    required this.dob,
    required this.countryCode,
    required this.mobile,
    required this.isSubscribed,
    this.subscriptionEndDate,
    this.subscriptionStartDate,
    this.deviceToken,
    this.authTokenIssuedAt,
    this.platform,
    required this.isNotification,
    this.contactSynch,
    required this.isAcceptTerms,
    required this.sortLastName,
    required this.isSuspended,
    required this.isDeleted,
    required this.created,
    required this.updated,
    required this.boardingSteps,
    this.webauth,
    this.isFreeUser,
    required this.isBiomatrix,
    required this.isDeviceBiometrics,
  });
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String userName;
  late final String? otp;
  late final String dob;
  late final String countryCode;
  late final String mobile;
  late final int? subscriptionEndDate;
  late final int? subscriptionStartDate;
  late final bool isSubscribed;
  late final String? deviceToken;
  late final int? authTokenIssuedAt;
  late final Null platform;
  late final bool isNotification;
  late final bool? contactSynch;
  late final bool isAcceptTerms;
  late final bool sortLastName;
  late final bool isSuspended;
  late final bool isDeleted;
  late final String created;
  late final String updated;
  late final String boardingSteps;
  late final bool? webauth;
  late final bool? isFreeUser;
  late final bool isBiomatrix;
  late final bool isDeviceBiometrics;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    firstName = json['firstName'] ?? '';
    lastName = json['lastName'] ?? '';
    userName = json['userName'] ?? '';
    otp = json['otp'];
    dob = json['dob'] ?? '';
    countryCode = json['countryCode'] ?? '';
    mobile = json['mobile'] ?? '';
    subscriptionEndDate = json['subscriptionEndDate'];
    subscriptionStartDate = json['subscriptionStartDate'];
    isSubscribed = json['isSubscribed'] ?? false;
    deviceToken = json['deviceToken'];
    authTokenIssuedAt = json['authTokenIssuedAt'];
    platform = null;
    isNotification = json['isNotification'] ?? false;
    contactSynch = json['contactSynch'];
    isAcceptTerms = json['isAcceptTerms'] ?? false;
    sortLastName = json['sortLastName'] ?? false;
    isSuspended = json['isSuspended'] ?? false;
    isDeleted = json['isDeleted'] ?? false;
    created = json['created'] ?? '';
    updated = json['updated'] ?? '';
    boardingSteps = json['boardingSteps'] ?? 'notification';
    webauth = json['webauth'];
    isFreeUser = json['isFreeUser'];
    isBiomatrix = json['isBiomatrix'] ?? false;
    isDeviceBiometrics = json['isDeviceBiometrics'] ?? false;
  }

  /// Converts the user object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the user's ID
  /// - `firstName`: the user's first name
  /// - `lastName`: the user's last name
  /// - `userName`: the user's username
  /// - `otp`: the one-time password, if available
  /// - `dob`: the user's date of birth
  /// - `countryCode`: the user's country code
  /// - `mobile`: the user's mobile number
  /// - `subscriptionEndDate`: the end date of the user's subscription, if available
  /// - `subscriptionStartDate`: the start date of the user's subscription, if available
  /// - `isSubscribed`: whether the user is subscribed
  /// - `deviceToken`: the user's device token, if available
  /// - `authTokenIssuedAt`: the timestamp when the auth token was issued, if available
  /// - `platform`: the user's platform, if available
  /// - `isNotification`: whether the user has notifications enabled
  /// - `contactSynch`: whether the user's contacts are synchronized, if available
  /// - `isAcceptTerms`: whether the user has accepted terms
  /// - `sortLastName`: whether the user's last name is sorted
  /// - `isSuspended`: whether the user is suspended
  /// - `isDeleted`: whether the user is deleted
  /// - `created`: the timestamp when the user was created
  /// - `updated`: the timestamp when the user was last updated
  /// - `boardingSteps`: the boarding steps for the user

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['userName'] = userName;
    data['otp'] = otp;
    data['dob'] = dob;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['subscriptionEndDate'] = subscriptionEndDate;
    data['subscriptionStartDate'] = subscriptionStartDate;
    data['isSubscribed'] = isSubscribed;
    data['deviceToken'] = deviceToken;
    data['authTokenIssuedAt'] = authTokenIssuedAt;
    data['platform'] = platform;
    data['isNotification'] = isNotification;
    data['contactSynch'] = contactSynch;
    data['isAcceptTerms'] = isAcceptTerms;
    data['sortLastName'] = sortLastName;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    data['boardingSteps'] = boardingSteps;
    data['webauth'] = webauth;
    data['isFreeUser'] = isFreeUser;
    data['isBiomatrix'] = isBiomatrix;
    data['isDeviceBiometrics'] = isDeviceBiometrics;
    return data;
  }

  /// H-STRIPE-02: Derived subscription status from existing fields.
  SubscriptionStatus get subscriptionStatus =>
      SubscriptionStatus.fromUserData(toJson());
}
