class ContactListModel {
  ContactListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  ContactListModel.fromJson(Map<String, dynamic> json) {
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
    required this.nextPage,
    required this.contacts,
  });
  late final bool nextPage;
  late final List<Contacts> contacts;

  Data.fromJson(Map<String, dynamic> json) {
    nextPage = json['nextPage'];
    contacts = List.from(json['contacts']).map((e) => Contacts.fromJson(e)).toList();
  }

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `nextPage`: a boolean indicating whether there is a next page
  /// - `contacts`: a list of maps representing the contacts in the response
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nextPage'] = nextPage;
    data['contacts'] = contacts.map((e) => e.toJson()).toList();
    return data;
  }
}

class Contacts {
  Contacts({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.company,
    this.phones,
    required this.emails,
  });
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String company;
  late final Null phones;
  late final List<Emails>? emails;

  Contacts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    company = json['company'];
    phones = null;
    emails = json['emails'] != null ? List.from(json['emails']).map((e) => Emails.fromJson(e)).toList() : null;
  }

  Null get initials => null;

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the contact ID
  /// - `firstName`: the contact first name
  /// - `lastName`: the contact last name
  /// - `company`: the contact company
  /// - `phones`: the contact phones, this is always null
  /// - `emails`: a list of maps representing the contact emails in the response
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['company'] = company;
    data['phones'] = phones;
    data['emails'] = emails?.map((e) => e.toJson()).toList();
    return data;
  }
}

class Emails {
  Emails({
    this.id,
    this.email,
  });
  late final int? id;
  late final String? email;

  Emails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `email`: the email address
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    return data;
  }
}
