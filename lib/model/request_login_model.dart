class RequestLogin {
  RequestLogin({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  RequestLogin.fromJson(Map<String, dynamic> json) {
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
  });
  late final User user;

  Data.fromJson(Map<String, dynamic> json) {
    user = User.fromJson(json['user']);
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The map will contain the following key:
  /// - `user`: a map representing the user, as returned by `User.toJson()`.

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user'] = user.toJson();
    return data;
  }
}

class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.countryCode,
    required this.mobile,
  });
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String userName;
  late final String countryCode;
  late final String mobile;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
  }

  /// Converts the `User` instance to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the user ID
  /// - `firstName`: the user first name
  /// - `lastName`: the user last name
  /// - `userName`: the user name
  /// - `countryCode`: the country code
  /// - `mobile`: the mobile number
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['userName'] = userName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    return data;
  }
}
