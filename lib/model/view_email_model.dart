class ViewEmailModel {
  ViewEmailModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  ViewEmailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    data = Data.fromJson(json['data']);
    message = json['message'] ?? '';
  }

  /// Converts the `ViewEmailModel` instance to a json-like map.
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
    this.url,
    required this.email,
  });
  late final String? url;
  late final Email email;

  Data.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    email = Email.fromJson(json['email']);
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `url`: a string containing the URL of the email (if any)
  /// - `email`: a map representing the email data, as returned by
  ///   `Email.toJson()`
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    data['email'] = email.toJson();
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
    this.s3Key,
    this.messageId,
    required this.isArchive,
    required this.isTrash,
    this.contentHeight,
    required this.isDeleted,
    required this.created,
    required this.updated,
    required this.receivers,
    required this.attachments,
    required this.sender,
    required this.emailTags,
    required this.communityStatus,
  });
  late final int id;
  late final int? senderId;
  late final String senderEmail;
  late final String subject;
  late final String message;
  late final String? messageText;
  late final Null s3Key;
  late final Null messageId;
  late final bool isArchive;
  late final bool isTrash;
  late final double? contentHeight;
  late final bool isDeleted;
  late final String created;
  late final String updated;
  late final List<Receivers> receivers;
  late final List<Attachments> attachments;
  late final Sender sender;
  late final List<EmailTags> emailTags;
  late final bool communityStatus;

  Email.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    senderId = json['senderId'];
    senderEmail = json['senderEmail'] ?? '';
    subject = json['subject'] ?? '';
    message = json['message'] ?? '';
    messageText = json['messageText'];
    s3Key = null;
    messageId = null;
    isArchive = json['isArchive'] ?? false;
    isTrash = json['isTrash'] ?? false;
    contentHeight = json['contentHeight'];
    isDeleted = json['isDeleted'] ?? false;
    created = json['created'] ?? '';
    updated = json['updated'] ?? '';
    receivers = json['receivers'] != null
        ? List.from(json['receivers'])
            .map((e) => Receivers.fromJson(e))
            .toList()
        : [];
    attachments = json['attachments'] != null
        ? List.from(json['attachments'])
            .map((e) => Attachments.fromJson(e))
            .toList()
        : [];
    sender = Sender.fromJson(json['sender']);
    emailTags = json['emailTags'] != null
        ? List.from(json['emailTags'])
            .map((e) => EmailTags.fromJson(e))
            .toList()
        : [];
    communityStatus = json['communityStatus'] ?? false;
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
  /// - `s3Key`: the S3 key for the email (optional)
  /// - `messageId`: the message ID (optional)
  /// - `isArchive`: a boolean indicating whether the email is archived
  /// - `isTrash`: a boolean indicating whether the email is in trash
  /// - `contentHeight`: the content height for the email
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `created`: the timestamp when the email was created
  /// - `updated`: the timestamp when the email was last updated
  /// - `receivers`: a list of maps representing the email receivers
  /// - `attachments`: a list of maps representing the email attachments
  /// - `sender`: a map representing the sender details
  /// - `emailTags`: a list of maps representing the email tags
  /// - `communityStatus`: a boolean indicating whether the email is a community status email
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['senderId'] = senderId;
    data['senderEmail'] = senderEmail;
    data['subject'] = subject;
    data['message'] = message;
    data['messageText'] = messageText;
    data['s3Key'] = s3Key;
    data['messageId'] = messageId;
    data['isArchive'] = isArchive;
    data['isTrash'] = isTrash;
    data['contentHeight'] = contentHeight;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    data['receivers'] = receivers.map((e) => e.toJson()).toList();
    data['attachments'] = attachments.map((e) => e.toJson()).toList();
    data['sender'] = sender.toJson();
    data['emailTags'] = emailTags.map((e) => e.toJson()).toList();
    data['communityStatus'] = communityStatus;
    return data;
  }
}

class Receivers {
  Receivers({
    required this.id,
    required this.emailId,
    this.draftId,
    this.receiverId,
    required this.receiverEmail,
    this.forwardEmail,
    required this.type,
    required this.isRead,
    required this.isTrash,
    required this.isArchive,
    required this.isDeleted,
    this.emailRecipientTags,
    required this.receiver,
  });
  late final int id;
  late final int emailId;
  late final Null draftId;
  late final int? receiverId;
  late final String receiverEmail;
  late final String? forwardEmail;
  late final String type;
  late final bool isRead;
  late final bool isTrash;
  late final bool isArchive;
  late final bool isDeleted;
  late final List<EmailRecipientTags>? emailRecipientTags;
  late final Receiver receiver;

  Receivers.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    emailId = json['emailId'] ?? 0;
    draftId = null;
    receiverId = json['receiverId'];
    receiverEmail = json['receiverEmail'] ?? '';
    forwardEmail = json['forwardEmail'];
    type = json['type'] ?? '';
    isRead = json['isRead'] ?? false;
    isTrash = json['isTrash'] ?? false;
    isArchive = json['isArchive'] ?? false;
    isDeleted = json['isDeleted'] ?? false;
    emailRecipientTags = json['emailRecipientTags'] != null
        ? List.from(json['emailRecipientTags'])
            .map((e) => EmailRecipientTags.fromJson(e))
            .toList()
        : [];
    receiver = Receiver.fromJson(json['receiver'] ?? {});
  }

  /// Converts the receiver data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the receiver ID
  /// - `emailId`: the ID of the email the receiver belongs to
  /// - `draftId`: the ID of the draft the receiver belongs to (if any)
  /// - `receiverId`: the ID of the receiver (if any)
  /// - `receiverEmail`: the email address of the receiver
  /// - `forwardEmail`: the forward email address of the receiver (if any)
  /// - `type`: the type of the receiver
  /// - `isRead`: a boolean indicating whether the email is read
  /// - `isTrash`: a boolean indicating whether the email is in trash
  /// - `isArchive`: a boolean indicating whether the email is archived
  /// - `isDeleted`: a boolean indicating whether the email is deleted
  /// - `emailRecipientTags`: a list of maps representing the email recipient tags
  /// - `receiver`: a map representing the receiver details
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['emailId'] = emailId;
    data['draftId'] = draftId;
    data['receiverId'] = receiverId;
    data['receiverEmail'] = receiverEmail;
    data['forwardEmail'] = forwardEmail;
    data['type'] = type;
    data['isRead'] = isRead;
    data['isTrash'] = isTrash;
    data['isArchive'] = isArchive;
    data['isDeleted'] = isDeleted;
    data['emailRecipientTags'] =
        emailRecipientTags?.map((e) => e.toJson()).toList();
    data['receiver'] = receiver.toJson();
    return data;
  }
}

class EmailRecipientTags {
  EmailRecipientTags({
    required this.id,
    required this.tagId,
    required this.emailRecipientsId,
    this.emailId,
    required this.tag,
  });
  late final int id;
  late final int tagId;
  late final int emailRecipientsId;
  late final Null emailId;
  late final Tag tag;

  EmailRecipientTags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tagId = json['tagId'];
    emailRecipientsId = json['emailRecipientsId'];
    emailId = null;
    tag = Tag.fromJson(json['tag']);
  }

  /// Converts the email recipient tags data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email recipient tag ID
  /// - `tagId`: the ID of the tag
  /// - `emailRecipientsId`: the ID of the email recipient
  /// - `emailId`: the ID of the email the tag belongs to (if any)
  /// - `tag`: a map representing the tag, as returned by `Tag.toJson()`
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['tagId'] = tagId;
    data['emailRecipientsId'] = emailRecipientsId;
    data['emailId'] = emailId;
    data['tag'] = tag.toJson();
    return data;
  }
}

class Tag {
  Tag({
    required this.id,
    required this.userId,
    required this.tag,
    required this.isSuspended,
    required this.isDeleted,
    required this.created,
    required this.updated,
  });
  late final int id;
  late final int userId;
  late final String tag;
  late final bool isSuspended;
  late final bool isDeleted;
  late final String created;
  late final String updated;

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    tag = json['tag'];
    isSuspended = json['isSuspended'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
  }

  /// Converts the `Tag` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
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
    data['userId'] = userId;
    data['tag'] = tag;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Receiver {
  Receiver({
    this.id,
    this.firstName,
    this.lastName,
  });
  late final int? id;
  late final String? firstName;
  late final String? lastName;

  Receiver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  /// Converts the receiver data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the receiver ID
  /// - `firstName`: the receiver's first name
  /// - `lastName`: the receiver's last name

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
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

  Sender.fromJson(Map<String, dynamic>? json) {
    id = json?['id'];
    firstName = json?['firstName'];
    lastName = json?['lastName'];
    created = json?['created'];
  }

  /// Converts the sender data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the sender ID
  /// - `firstName`: the sender's first name
  /// - `lastName`: the sender's last name
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

class EmailTags {
  EmailTags({
    required this.id,
    required this.userId,
    required this.tag,
    required this.isSuspended,
    required this.isDeleted,
    required this.created,
    required this.updated,
  });
  late final int id;
  late final int userId;
  late final String tag;
  late final bool isSuspended;
  late final bool isDeleted;
  late final String created;
  late final String updated;

  EmailTags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    tag = json['tag'];
    isSuspended = json['isSuspended'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
  }

  /// Converts the `EmailTags` instance to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the ID of the email tag
  /// - `userId`: the ID of the user who created the tag
  /// - `tag`: the tag value
  /// - `isSuspended`: a boolean indicating whether the tag is suspended
  /// - `isDeleted`: a boolean indicating whether the tag is deleted
  /// - `created`: the date and time when the tag was created
  /// - `updated`: the date and time when the tag was last updated

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['tag'] = tag;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Attachments {
  Attachments({
    this.id,
    this.type,
    this.path,
    this.emailId,
    this.size,
    this.draftId,
  });
  late final int? id;
  late final String? type;
  late final String? path;
  late final int? emailId;
  late final int? size;
  late final Null draftId;

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    path = json['path'];
    size = json['size'];
    emailId = json['emailId'];
    draftId = null;
  }

  /// Converts the attachment data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the attachment ID
  /// - `type`: the type of attachment
  /// - `path`: the path to the attachment
  /// - `size`: the size of the attachment (if available)
  /// - `emailId`: the ID of the email the attachment belongs to (if any)
  /// - `draftId`: the ID of the draft the attachment belongs to (if any)

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['path'] = path;
    data['size'] = size;
    data['emailId'] = emailId;
    data['draftId'] = draftId;
    return data;
  }
}
