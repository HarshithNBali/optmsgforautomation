class NotificationListModel {
  NotificationListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  NotificationListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `NotificationListModel` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
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
    required this.notifications,
  });
  late final List<Notifications> notifications;

  Data.fromJson(Map<String, dynamic> json) {
    notifications = List.from(json['notifications']).map((e) => Notifications.fromJson(e)).toList();
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain a single key, `notifications`, which is a list
  /// of maps representing the notifications, as returned by `Notifications.toJson()`.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['notifications'] = notifications.map((e) => e.toJson()).toList();
    return data;
  }
}

class Notifications {
  Notifications({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.userId,
    required this.info,
    required this.isRead,
    required this.isDeleted,
    required this.created,
    required this.updated,
  });
  late final int id;
  late final String type;
  late final String title;
  late final String body;
  late final int userId;
  late final Info info;
  bool? isRead;
  late final bool isDeleted;
  late final String created;
  late final String updated;

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    body = json['body'];
    userId = json['userId'];
    info = Info.fromJson(json['info']);
    isRead = json['isRead'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
  }

  /// Converts the `Notifications` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `id`: the notification ID
  /// - `type`: the type of notification
  /// - `title`: the title of the notification
  /// - `body`: the body of the notification
  /// - `userId`: the ID of the user who created the notification
  /// - `info`: a map representing the notification info, as returned by `Info.toJson()`
  /// - `isRead`: a boolean indicating whether the notification has been read
  /// - `isDeleted`: a boolean indicating whether the notification is deleted
  /// - `created`: the date and time when the notification was created
  /// - `updated`: the date and time when the notification was last updated
  Notifications copyWith({bool? isRead}) {
    return Notifications(
      id: id,
      type: type,
      title: title,
      body: body,
      userId: userId,
      info: info,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted,
      created: created,
      updated: updated,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['body'] = body;
    data['userId'] = userId;
    data['info'] = info.toJson();
    data['isRead'] = isRead;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Info {
  Info({
    this.emailId,
  });
  late final int? emailId;

  Info.fromJson(Map<String, dynamic> json) {
    emailId = json['emailId'];
  }

  /// Converts the `Info` instance to a json-like map.
  ///
  /// The resulting map will contain a single key, `emailId`, which is the ID of
  /// the email associated with the notification.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['emailId'] = emailId;
    return data;
  }
}
