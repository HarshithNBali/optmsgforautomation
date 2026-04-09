class SignedUrlModel {
  SignedUrlModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  SignedUrlModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `SignedUrlModel` instance to a json-like map.
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
    required this.url,
    required this.preview,
    required this.fileName,
  });
  late final String url;
  late final String preview;
  late final String fileName;

  Data.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    preview = json['preview'];
    fileName = json['fileName'];
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain the following keys:
  /// - `url`: a string representing the signed URL
  /// - `preview`: a string representing a preview of the file
  /// - `fileName`: a string representing the name of the file
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    data['preview'] = preview;
    data['fileName'] = fileName;

    return data;
  }
}
