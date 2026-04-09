class TagsListModel {
  TagsListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  TagsListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `TagsListModel` instance to a json-like map.
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
    required this.tags,
  });
  late final List<Tags> tags;

  Data.fromJson(Map<String, dynamic> json) {
    tags = List.from(json['tags']).map((e) => Tags.fromJson(e)).toList();
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain a single key, `tags`, which is a list of maps
  /// representing the tags in the response, as returned by `Tags.toJson()`.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tags'] = tags.map((e) => e.toJson()).toList();
    return data;
  }
}

class Tags {
  Tags({
    required this.id,
    required this.tag,
  });
  late final int id;
  late final String tag;

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tag = json['tag'];
  }

  /// Converts the `Tags` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `id`: the ID of the tag
  /// - `tag`: the tag value
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['tag'] = tag;
    return data;
  }
}
