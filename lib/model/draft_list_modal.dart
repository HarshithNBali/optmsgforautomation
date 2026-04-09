class DraftListModel {
  DraftListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  DraftListModel.fromJson(Map<String, dynamic> json) {
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
    required this.nextPage,
  });
  late final List<Emails> emails;
  late final bool nextPage;

  Data.fromJson(Map<String, dynamic> json) {
    emails = List.from(json['emails']).map((e) => Emails.fromJson(e)).toList();
    nextPage = json['nextPage'];
  }

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `emails`: a list of maps representing the emails in the response
  /// - `nextPage`: a boolean indicating whether there is a next page
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['emails'] = emails.map((e) => e.toJson()).toList();
    data['nextPage'] = nextPage;
    return data;
  }
}

class Emails {
  Emails({
    required this.id,
    required this.senderId,
    required this.subject,
    required this.message,
    required this.isDeleted,
    required this.created,
    required this.updated,
    required this.attachments,
  });
  late final int id;
  late final int senderId;
  late final String subject;
  late final String message;
  late final bool isDeleted;
  late final String created;
  late final String updated;
  late final List<Attachments> attachments;

  Emails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    subject = json['subject'];
    message = json['message'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
    attachments = List.from(json['attachments']).map((e) => Attachments.fromJson(e)).toList();
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `senderId`: the ID of the sender
  /// - `subject`: the subject of the email
  /// - `message`: the body of the email
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `created`: the creation date of the email
  /// - `updated`: the last updated date of the email
  /// - `attachments`: a list of maps representing the email attachments

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['senderId'] = senderId;
    data['subject'] = subject;
    data['message'] = message;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    data['attachments'] = attachments.map((e) => e.toJson()).toList();
    return data;
  }
}

class Attachments {
  Attachments({
    required this.id,
    required this.type,
    required this.path,
    this.emailId,
    required this.draftId,
  });
  late final int id;
  late final String type;
  late final String path;
  late final Null emailId;
  late final int draftId;

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    path = json['path'];
    emailId = null;
    draftId = json['draftId'];
  }

  /// Converts the attachment data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the attachment ID
  /// - `type`: the type of attachment
  /// - `path`: the path to the attachment
  /// - `emailId`: the ID of the email the attachment belongs to (if any)
  /// - `draftId`: the ID of the draft the attachment belongs to (if any)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['path'] = path;
    data['emailId'] = emailId;
    data['draftId'] = draftId;
    return data;
  }
}
