class FaqStaticPage {
  bool? success;
  Data? data;
  String? message;

  FaqStaticPage({this.success, this.data, this.message});

  FaqStaticPage.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `success`: a boolean indicating whether the request was successful
  /// - `data`: a map representing the data in the response
  /// - `message`: a string containing a message from the server
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  List<Faq>? faq;

  Data({this.faq});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['faq'] != null) {
      faq = <Faq>[];
      json['faq'].forEach((v) {
        faq!.add(Faq.fromJson(v));
      });
    }
  }

  /// Converts the object to a json-like map.
  ///
  /// The map will contain the following key:
  /// - `faq`: a list of maps representing the FAQs in the response, as returned
  ///   by `Faq.toJson()`.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (faq != null) {
      data['faq'] = faq!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Faq {
  int? id;
  String? question;
  String? answer;

  Faq({this.id, this.question, this.answer});

  Faq.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
  }

  /// Converts the FAQ object to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the ID of the FAQ
  /// - `question`: the question text
  /// - `answer`: the answer text

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }
}
