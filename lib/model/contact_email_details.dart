import 'dart:convert';

ContactEmailDetailsModel contactEmailDetailsModelFromJson(String str) => ContactEmailDetailsModel.fromJson(json.decode(str));

String contactEmailDetailsModelToJson(ContactEmailDetailsModel data) => json.encode(data.toJson());

class ContactEmailDetailsModel {
  bool? success;
  Data? data;
  String? message;

  ContactEmailDetailsModel({
    this.success,
    this.data,
    this.message,
  });

  factory ContactEmailDetailsModel.fromJson(Map<String, dynamic> json) => ContactEmailDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `success`: a boolean indicating whether the request was successful
  /// - `data`: a map representing the data in the response
  /// - `message`: a string containing a message from the server
  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  List<Contact>? contacts;

  Data({
    this.contacts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        contacts: json["contacts"] == null ? [] : List<Contact>.from(json["contacts"]!.map((x) => Contact.fromJson(x))),
      );

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following key:
  /// - `contacts`: a list of maps representing the contacts, or an empty list if no contacts are available

  Map<String, dynamic> toJson() => {
        "contacts": contacts == null ? [] : List<dynamic>.from(contacts!.map((x) => x.toJson())),
      };
}

class Contact {
  int? id;
  String? email;
  bool? isDeleted;

  Contact({
    this.id,
    this.email,
    this.isDeleted,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json["id"],
        email: json["email"],
        isDeleted: json["isDeleted"],
      );

  /// Converts the contact data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the contact ID
  /// - `email`: the contact email
  /// - `isDeleted`: a boolean indicating whether the contact is deleted
  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "isDeleted": isDeleted,
      };
}
