class ViewDraftModel {
  ViewDraftModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  ViewDraftModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `ViewDraftModel` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `success`: a boolean indicating whether the request was successful
  /// - `data`: a map representing the data in the response, as returned by
  ///   `Data.toJson()`
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
    required this.email,
  });
  late final Email email;

  Data.fromJson(Map<String, dynamic> json) {
    email = Email.fromJson(json['email']);
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain the following key:
  /// - `email`: a map representing the email data, as returned by
  ///   `Email.toJson()`
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['email'] = email.toJson();
    return data;
  }
}

class Email {
  Email({
    required this.id,
    required this.senderId,
    required this.subject,
    required this.message,
    required this.isDeleted,
    required this.created,
    required this.updated,
    required this.receivers,
    required this.attachments,
    required this.sender,
  });
  late final int id;
  late final int senderId;
  late final String subject;
  late final String message;
  late final bool isDeleted;
  late final String created;
  late final String updated;
  late final List<Receivers> receivers;
  late final List<Attachments> attachments;
  late final Sender sender;

  Email.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    subject = json['subject'];
    message = json['message'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
    receivers = List.from(json['receivers']).map((e) => Receivers.fromJson(e)).toList();
    attachments = List.from(json['attachments']).map((e) => Attachments.fromJson(e)).toList();
    sender = Sender.fromJson(json['sender']);
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `senderId`: the ID of the sender
  /// - `subject`: the email subject
  /// - `message`: the email message
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `created`: the timestamp when the email was created
  /// - `updated`: the timestamp when the email was last updated
  /// - `receivers`: a list of maps representing the email receivers
  /// - `attachments`: a list of maps representing the email attachments
  /// - `sender`: a map representing the sender details
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['senderId'] = senderId;
    data['subject'] = subject;
    data['message'] = message;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    data['receivers'] = receivers.map((e) => e.toJson()).toList();
    data['attachments'] = attachments.map((e) => e.toJson()).toList();
    data['sender'] = sender.toJson();
    return data;
  }
}

class Receivers {
  Receivers({
    required this.id,
    this.emailId,
    required this.draftId,
    this.receiverId,
    required this.receiverEmail,
    required this.type,
    required this.isRead,
    required this.isTrash,
    required this.isArchive,
    required this.isDeleted,
    required this.receiver,
  });
  late final int id;
  late final Null emailId;
  late final int draftId;
  late final Null receiverId;
  late final String receiverEmail;
  late final String type;
  late final bool isRead;
  late final bool isTrash;
  late final bool isArchive;
  late final bool isDeleted;
  late final Receiver receiver;

  Receivers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    emailId = null;
    draftId = json['draftId'];
    receiverId = null;
    receiverEmail = json['receiverEmail'];
    type = json['type'];
    isRead = json['isRead'];
    isTrash = json['isTrash'];
    isArchive = json['isArchive'];
    isDeleted = json['isDeleted'];
    receiver = Receiver.fromJson(json['receiver']);
  }

  /// Converts the data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the receiver ID
  /// - `emailId`: the ID of the email the receiver belongs to
  /// - `draftId`: the ID of the draft the receiver belongs to (if any)
  /// - `receiverId`: the ID of the receiver (if any)
  /// - `receiverEmail`: the email address of the receiver
  /// - `type`: the type of the receiver
  /// - `isRead`: a boolean indicating whether the email is read
  /// - `isTrash`: a boolean indicating whether the email is in trash
  /// - `isArchive`: a boolean indicating whether the email is archived
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `receiver`: a map representing the receiver details
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['emailId'] = emailId;
    data['draftId'] = draftId;
    data['receiverId'] = receiverId;
    data['receiverEmail'] = receiverEmail;
    data['type'] = type;
    data['isRead'] = isRead;
    data['isTrash'] = isTrash;
    data['isArchive'] = isArchive;
    data['isDeleted'] = isDeleted;
    data['receiver'] = receiver.toJson();
    return data;
  }
}

class Receiver {
  Receiver({
    required this.firstName,
    required this.lastName,
  });
  late final String? firstName;
  late final String lastName;

  Receiver.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  /// Converts the receiver data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `firstName`: the receiver first name
  /// - `lastName`: the receiver last name
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    return data;
  }
}

class Attachments {
  Attachments({
    required this.id,
    required this.type,
    required this.path,
    this.size,
    this.fileName,
  });
  late final int id;
  late final String type;
  late final String path;
  late final int? size;
  late final String? fileName;

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    path = json['path'];
    size = json['size'];
    fileName = json['fileName'];
  }

  /// Converts the attachment data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the attachment ID
  /// - `type`: the type of attachment
  /// - `path`: the path to the attachment
  /// - `size`: the size of the attachment (if available)
  /// - `fileName`: the original file name (if available)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['path'] = path;
    data['size'] = size;
    data['fileName'] = fileName;

    return data;
  }
}

class Sender {
  Sender({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.created,
  });
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String created;

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    created = json['created'];
  }

  /// Converts the sender data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the sender ID
  /// - `firstName`: the sender first name
  /// - `lastName`: the sender last name
  /// - `created`: the timestamp when the sender was created
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['created'] = created;
    return data;
  }
}
