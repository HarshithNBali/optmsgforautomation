class SentListModel {
  SentListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  SentListModel.fromJson(Map<String, dynamic> json) {
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

  /// Converts the object to a json-like map.
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
  int? id;
  dynamic senderId;
  String? senderEmail;
  String? senderName;
  String? subject;
  String? messageText;
  dynamic messageStatus;
  DateTime? created;
  List<Attachments>? attachments;
  List<Receivers>? receivers;
  Sender? sender;
  List<EmailTag>? emailTag;
  String? message;
  bool? communityStatus;
  bool? isDraft;

  Emails({
    this.id,
    this.senderId,
    this.senderEmail,
    this.senderName,
    this.subject,
    this.messageText,
    this.messageStatus,
    this.created,
    this.attachments,
    this.receivers,
    this.sender,
    this.emailTag,
    this.message,
    this.communityStatus,
    this.isDraft,
  });

  factory Emails.fromJson(Map<String, dynamic> json) => Emails(
        id: json["id"],
        senderId: json["senderId"],
        senderEmail: json["senderEmail"],
        senderName: json["senderName"],
        subject: json["subject"],
        messageText: json["messageText"],
        messageStatus: json["messageStatus"],
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
        attachments: json["attachments"] == null ? [] : List<Attachments>.from(json["attachments"]!.map((x) => Attachments.fromJson(x))),
        receivers: json["receivers"] == null ? [] : List<Receivers>.from(json["receivers"]!.map((x) => Receivers.fromJson(x))),
        sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
        emailTag: json["emailTag"] == null ? [] : List<EmailTag>.from(json["emailTag"]!.map((x) => EmailTag.fromJson(x))),
        message: json["message"],
        communityStatus: json["communityStatus"],
        isDraft: json["isDraft"],
      );

  Emails copyWith({
    int? id,
    dynamic senderId,
    String? senderEmail,
    String? senderName,
    String? subject,
    String? messageText,
    dynamic messageStatus,
    DateTime? created,
    List<Attachments>? attachments,
    List<Receivers>? receivers,
    Sender? sender,
    List<EmailTag>? emailTag,
    String? message,
    bool? communityStatus,
    bool? isDraft,
  }) {
    return Emails(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderEmail: senderEmail ?? this.senderEmail,
      senderName: senderName ?? this.senderName,
      subject: subject ?? this.subject,
      messageText: messageText ?? this.messageText,
      messageStatus: messageStatus ?? this.messageStatus,
      created: created ?? this.created,
      attachments: attachments ?? this.attachments,
      receivers: receivers ?? this.receivers,
      sender: sender ?? this.sender,
      emailTag: emailTag ?? this.emailTag,
      message: message ?? this.message,
      communityStatus: communityStatus ?? this.communityStatus,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "senderId": senderId,
        "senderEmail": senderEmail,
        "senderName": senderName,
        "subject": subject,
        "messageText": messageText,
        "messageStatus": messageStatus,
        "created": created?.toIso8601String(),
        "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x.toJson())),
        "receivers": receivers == null ? [] : List<dynamic>.from(receivers!.map((x) => x.toJson())),
        "sender": sender?.toJson(),
        "emailTag": emailTag == null ? [] : List<dynamic>.from(emailTag!.map((x) => x.toJson())),
        "message": message,
        "communityStatus": communityStatus,
        "isDraft": isDraft,
      };
}

class Attachments {
  int? id;

  Attachments({
    this.id,
  });

  factory Attachments.fromJson(Map<String, dynamic> json) => Attachments(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}

class Receivers {
  int? emailId;
  String? receiverEmail;
  int? id;
  bool? isRead;

  List<dynamic>? emailRecipientTags;
  Receiver? receiver;

  Receivers({
    this.emailId,
    this.receiverEmail,
    this.id,
    this.isRead,
    this.emailRecipientTags,
    this.receiver,
  });

  factory Receivers.fromJson(Map<String, dynamic> json) => Receivers(
        emailId: json["emailId"],
        receiverEmail: json["receiverEmail"],
        id: json["id"],
        isRead: json["isRead"],
        emailRecipientTags: json["emailRecipientTags"] == null ? [] : List<dynamic>.from(json["emailRecipientTags"]!.map((x) => x)),
        receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
      );

  Receivers copyWith({
    int? emailId,
    String? receiverEmail,
    int? id,
    bool? isRead,
    List<dynamic>? emailRecipientTags,
    Receiver? receiver,
  }) {
    return Receivers(
      emailId: emailId ?? this.emailId,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
      emailRecipientTags: emailRecipientTags ?? this.emailRecipientTags,
      receiver: receiver ?? this.receiver,
    );
  }

  Map<String, dynamic> toJson() => {
        "emailId": emailId,
        "receiverEmail": receiverEmail,
        "id": id,
        "isRead": isRead,
        "emailRecipientTags": emailRecipientTags == null ? [] : List<dynamic>.from(emailRecipientTags!.map((x) => x)),
        "receiver": receiver?.toJson(),
      };
}

class Receiver {
  Receiver({
    required this.firstName,
    required this.lastName,
    required this.userName,
  });
  late final String? firstName;
  late final String lastName;
  late final String userName;

  Receiver.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
  }

  /// Converts the receiver data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `firstName`: the receiver first name
  /// - `lastName`: the receiver last name
  /// - `userName`: the receiver user name
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['userName'] = userName;
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

class EmailTag {
  EmailTag({
    required this.id,
    required this.tagId,
    this.emailRecipientsId,
    this.emailId,
    required this.tag,
  });
  late final int id;
  late final int tagId;
  late final Null emailRecipientsId;
  late final int? emailId;
  late final Tag tag;

  EmailTag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tagId = json['tagId'];
    emailRecipientsId = null;
    emailId = json['emailId'];
    tag = Tag.fromJson(json['tag']);
  }

  /// Converts the email tag data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the email tag ID
  /// - `tagId`: the ID of the tag
  /// - `emailRecipientsId`: the ID of the email recipient (if any)
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
