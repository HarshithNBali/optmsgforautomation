class StaticPage {
  StaticPage({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  StaticPage.fromJson(Map<String, dynamic> json) {
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
    required this.page,
  });
  late final Page page;

  Data.fromJson(Map<String, dynamic> json) {
    page = Page.fromJson(json['page']);
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain a single key, `page`, which is a map
  /// representing the page in the response, as returned by `Page.toJson()`.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['page'] = page.toJson();
    return data;
  }
}

class Page {
  Page({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.isSuspended,
    required this.isDeleted,
    required this.created,
    required this.updated,
  });
  late final int id;
  late final String title;
  late final String slug;
  late final String description;
  late final bool isSuspended;
  late final bool isDeleted;
  late final String created;
  late final String updated;

  Page.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    isSuspended = json['isSuspended'];
    isDeleted = json['isDeleted'];
    created = json['created'];
    updated = json['updated'];
  }

  /// Converts the page data to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the page ID
  /// - `title`: the page title
  /// - `slug`: the page slug
  /// - `description`: the page description
  /// - `isSuspended`: a boolean indicating whether the page is suspended
  /// - `isDeleted`: a boolean indicating whether the page is deleted
  /// - `created`: the timestamp when the page was created
  /// - `updated`: the timestamp when the page was last updated
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['isSuspended'] = isSuspended;
    data['isDeleted'] = isDeleted;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
