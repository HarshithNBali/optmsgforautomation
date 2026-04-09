class SearchEmailModel {
  SearchEmailModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  SearchEmailModel.fromJson(Map<String, dynamic> json) {
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
    required this.emails,
  });
  late final List<Emails> emails;

  Data.fromJson(Map<String, dynamic> json) {
    emails = List.from(json['emails']).map((e) => Emails.fromJson(e)).toList();
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `emails`: a list of maps representing the emails in the response
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['emails'] = emails.map((e) => e.toJson()).toList();
    return data;
  }
}

class Emails {
  Emails({
    required this.id,
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.company,
  });
  late final int id;
  late final int userId;
  late final String email;
  late final String? firstName;
  late final String? lastName;
  late final String? company;

  Emails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    company = json['company'];
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `userId`: the ID of the user associated with the email
  /// - `email`: the email address
  /// - `firstName`: the first name associated with the email (optional)
  /// - `lastName`: the last name associated with the email (optional)
  /// - `company`: the company associated with the email (optional)

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['company'] = company;
    return data;
  }
}
