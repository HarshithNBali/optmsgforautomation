class InboxListModel {
  InboxListModel({
    required this.success,
    this.data,
    required this.message,
  });

  late final bool success;
  Data? data; // nullable
  late final String message;

  InboxListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;

    // ✅ FIX: protect against null data
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = Data.fromJson(json['data']);
    } else {
      data = null;
    }

    message = json['message'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;

    // ✅ FIX: avoid null crash
    if (data != null) {
      map['data'] = data!.toJson();
    }

    map['message'] = message;
    return map;
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
    required this.emailId,
    this.draftId,
    required this.receiverId,
    required this.isRead,
    required this.email,
    required this.emailRecipientTags,
  });
  late final int id;
  late final int emailId;
  late final Null draftId;
  late final int receiverId;

  late bool isRead;

  late final Email email;
  late List<EmailRecipientTags> emailRecipientTags;

  Emails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    emailId = json['emailId'];
    draftId = null;
    receiverId = json['receiverId'];

    isRead = json['isRead'];

    email = Email.fromJson(json['email']);
    if (json['emailRecipientTags'] != null && json['emailRecipientTags'] is List && json['emailRecipientTags'].isNotEmpty) {
      emailRecipientTags = List.from(json['emailRecipientTags']).map((e) => EmailRecipientTags.fromJson(e)).toList();
    } else {
      emailRecipientTags = [];
    }
  }

  Emails copyWith({
    int? id,
    int? emailId,
    int? receiverId,
    bool? isRead,
    Email? email,
    List<EmailRecipientTags>? emailRecipientTags,
  }) {
    return Emails(
      id: id ?? this.id,
      emailId: emailId ?? this.emailId,
      receiverId: receiverId ?? this.receiverId,
      isRead: isRead ?? this.isRead,
      email: email ?? this.email,
      emailRecipientTags: emailRecipientTags ?? List<EmailRecipientTags>.from(this.emailRecipientTags),
    );
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `emailId`: the ID of the email
  /// - `draftId`: the ID of the draft (nullable)
  /// - `receiverId`: the receiver ID
  /// - `receiverEmail`: the receiver's email address
  /// - `type`: the type of email
  /// - `isRead`: a boolean indicating whether the email is read
  /// - `isTrash`: a boolean indicating whether the email is in trash
  /// - `isArchive`: a boolean indicating whether the email is archived
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `email`: a map representing the email details
  /// - `emailRecipientTags`: a list of maps representing the email recipient tags

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['emailId'] = emailId;
    data['draftId'] = draftId;
    data['receiverId'] = receiverId;

    data['isRead'] = isRead;

    data['email'] = email.toJson();
    data['emailRecipientTags'] = emailRecipientTags.map((e) => e.toJson()).toList();
    return data;
  }
}

class Email {
  Email({
    required this.id,
    this.senderId,
    required this.senderEmail,
    required this.subject,
    required this.message,
    this.messageText,
    // required this.isArchive,
    // required this.isDeleted,
    required this.created,
    // required this.updated,
    required this.attachments,
    required this.sender,
  });
  late final int id;
  late final int? senderId;
  late final String senderEmail;
  late final String subject;
  late final String message;
  late final String? messageText;
  // late final bool isArchive;
  // late final bool isDeleted;
  late final String created;
  // late final String updated;
  late final List<Attachments> attachments;
  late final Sender sender;

  Email.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    senderEmail = json['senderEmail'];
    subject = json['subject'];
    message = json['message'];
    messageText = json['messageText'];
    // isArchive = json['isArchive'];
    // isDeleted = json['isDeleted'];
    created = json['created'];
    // updated = json['updated'];
    attachments = List.from(json['attachments']).map((e) => Attachments.fromJson(e)).toList();
    sender = Sender.fromJson(json['sender']);
  }

  /// Converts the email data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email ID
  /// - `senderId`: the ID of the sender
  /// - `senderEmail`: the sender's email address
  /// - `subject`: the email subject
  /// - `message`: the email message
  /// - `messageText`: the email message text (optional)
  /// - `isArchive`: a boolean indicating whether the email is archived
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `created`: the timestamp when the email was created
  /// - `updated`: the timestamp when the email was last updated
  /// - `attachments`: a list of maps representing the email attachments
  /// - `sender`: a map representing the sender details
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['senderId'] = senderId;
    data['senderEmail'] = senderEmail;
    data['subject'] = subject;
    data['message'] = message;
    data['messageText'] = messageText;
    // data['isArchive'] = isArchive;
    // data['isDeleted'] = isDeleted;
    data['created'] = created;
    // data['updated'] = updated;
    data['attachments'] = attachments.map((e) => e.toJson()).toList();
    data['sender'] = sender.toJson();
    return data;
  }
}

class Attachments {
  Attachments({
    required this.id,
    this.type,
    this.path,
    this.draftId,
  });
  late final int id;
  late final String? type;
  late final String? path;
  late final String? draftId;

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = null;
    path = null;
    draftId = null;
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
    data['draftId'] = draftId;
    return data;
  }
}

class Sender {
  Sender({
    this.id,
    this.firstName,
    this.lastName,
    this.created,
  });
  late final int? id;
  late final String? firstName;
  late final String? lastName;
  late final String? created;

  Sender.fromJson(Map<String, dynamic> json) {
    id = null;
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

class EmailRecipientTags {
  EmailRecipientTags({
    required this.id,
    required this.tagId,
    required this.emailRecipientsId,
    required this.tag,
  });
  late final int id;
  late final int tagId;
  late final int emailRecipientsId;
  late final Tag tag;

  EmailRecipientTags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tagId = json['tagId'];
    emailRecipientsId = json['emailRecipientsId'];
    tag = Tag.fromJson(json['tag']);
  }

  /// Converts the email recipient tags data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email recipient tag ID
  /// - `tagId`: the ID of the tag
  /// - `emailRecipientsId`: the ID of the email recipient
  /// - `tag`: a map representing the tag, as returned by `Tag.toJson()`
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['tagId'] = tagId;
    data['emailRecipientsId'] = emailRecipientsId;
    data['tag'] = tag.toJson();
    return data;
  }
}

class Tag {
  Tag({
    required this.id,
    required this.tag,
  });
  late final int id;

  late final String tag;

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    tag = json['tag'];
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the ID of the tag
  /// - `userId`: the ID of the user who created the tag
  /// - `tag`: the tag value
  /// - `isSuspended`: a boolean indicating whether the tag is suspended
  /// - `isDeleted`: a boolean indicating whether the tag is deleted
  /// - `created`: the date and time when the tag was created
  /// - `updated`: the date and time when the tag was last updated
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['tag'] = tag;
    return data;
  }
}
