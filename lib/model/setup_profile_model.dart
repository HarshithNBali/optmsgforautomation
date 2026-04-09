class SetupProfile {
  SetupProfile({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  SetupProfile.fromJson(Map<String, dynamic> json) {
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
    required this.user,
    required this.token,
  });
  late final User user;
  late final String token;

  Data.fromJson(Map<String, dynamic> json) {
    user = User.fromJson(json['user']);
    token = json['token'];
  }

  /// Converts the object to a json-like map.
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
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.dob,
    required this.countryCode,
    required this.phone,
    required this.authTokenIssuedAt,
    required this.created,
    required this.updated,
    this.otp,
    this.stripeCustomerId,
    this.stripeSubscriptionKey,
    this.subscriptionEndDate,
    this.planId,
    this.deviceToken,
    this.platform,
    this.tempMobile,
    this.tempOtpId,
    this.txnToken,
    required this.id,
    required this.isSubscriptionCancel,
    required this.isSubscribed,
    required this.isNotification,
    required this.isAcceptTerms,
    required this.isContactSynch,
    required this.isBiomatrix,
    required this.isSuspended,
    required this.isDeleted,
  });
  late final String firstName;
  late final String lastName;
  late final String userName;
  late final String dob;
  late final String countryCode;
  late final String phone;
  late final int authTokenIssuedAt;
  late final String created;
  late final String updated;
  late final Null otp;
  late final Null stripeCustomerId;
  late final Null stripeSubscriptionKey;
  late final Null subscriptionEndDate;
  late final Null planId;
  late final Null deviceToken;
  late final Null platform;
  late final Null tempMobile;
  late final Null tempOtpId;
  late final Null txnToken;
  late final int id;
  late final bool isSubscriptionCancel;
  late final bool isSubscribed;
  late final bool isNotification;
  late final bool isAcceptTerms;
  late final bool isContactSynch;
  late final bool isBiomatrix;
  late final bool isSuspended;
  late final bool isDeleted;

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
    dob = json['dob'];
    countryCode = json['countryCode'];
    phone = json['phone'];
    authTokenIssuedAt = json['authTokenIssuedAt'];
    created = json['created'];
    updated = json['updated'];
    otp = null;
    stripeCustomerId = null;
    stripeSubscriptionKey = null;
    subscriptionEndDate = null;
    planId = null;
    deviceToken = null;
    platform = null;
    tempMobile = null;
    tempOtpId = null;
    txnToken = null;
    id = json['id'];
    isSubscriptionCancel = json['isSubscriptionCancel'];
    isSubscribed = json['isSubscribed'];
    isNotification = json['isNotification'];
    isAcceptTerms = json['isAcceptTerms'];
    isContactSynch = json['isContactSynch'];
    isBiomatrix = json['isBiomatrix'];
    isSuspended = json['isSuspended'];
    isDeleted = json['isDeleted'];
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `firstName`: the user first name
  /// - `lastName`: the user last name
  /// - `userName`: the user name
  /// - `dob`: the date of birth
  /// - `countryCode`: the country code
  /// - `phone`: the mobile number
  /// - `authTokenIssuedAt`: the auth token issued at timestamp
  /// - `created`: the created timestamp
  /// - `updated`: the updated timestamp
  /// - `otp`: the one-time password (if available)
  /// - `stripeCustomerId`: the Stripe customer ID (if available)
  /// - `stripeSubscriptionKey`: the Stripe subscription key (if available)
  /// - `subscriptionEndDate`: the subscription end date (if available)
  /// - `planId`: the plan ID (if available)
  /// - `deviceToken`: the device token
  /// - `platform`: the platform
  /// - `tempMobile`: the temporary mobile number
  /// - `tempOtpId`: the temporary OTP ID
  /// - `txnToken`: the transaction token
  /// - `id`: the user ID
  /// - `isSubscriptionCancel`: a boolean indicating whether the subscription is canceled
  /// - `isSubscribed`: a boolean indicating whether the user is subscribed
  /// - `isNotification`: a boolean indicating whether the user has notifications
  /// - `isAcceptTerms`: a boolean indicating whether the user has accepted terms
  /// - `isContactSynch`: a boolean indicating whether the user has contact synch
  /// - `isBiomatrix`: a boolean indicating whether the user has biomatrix
  /// - `isSuspended`: a boolean indicating whether the user is suspended
  /// - `isDeleted`: a boolean indicating whether the user is deleted
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['userName'] = userName;
    data['dob'] = dob;
    data['countryCode'] = countryCode;
    data['phone'] = phone;
    data['authTokenIssuedAt'] = authTokenIssuedAt;
    data['created'] = created;
    data['updated'] = updated;
    data['otp'] = otp;
    data['stripeCustomerId'] = stripeCustomerId;
    data['stripeSubscriptionKey'] = stripeSubscriptionKey;
    data['subscriptionEndDate'] = subscriptionEndDate;
    data['planId'] = planId;
    data['deviceToken'] = deviceToken;
    data['platform'] = platform;
    data['tempMobile'] = tempMobile;
    data['tempOtpId'] = tempOtpId;
    data['txnToken'] = txnToken;
    data['id'] = id;
    data['isSubscriptionCancel'] = isSubscriptionCancel;
    data['isSubscribed'] = isSubscribed;
    data['isNotification'] = isNotification;
    data['isAcceptTerms'] = isAcceptTerms;
    data['isContactSynch'] = isContactSynch;
    data['isBiomatrix'] = isBiomatrix;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    return data;
  }
}
