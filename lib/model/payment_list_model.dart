class PaymentListModel {
  PaymentListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  PaymentListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the model to a json-like map.
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
    required this.plan,
    required this.paymentList,
  });
  late final Plan plan;
  late final List<PaymentList> paymentList;

  Data.fromJson(Map<String, dynamic> json) {
    plan = Plan.fromJson(json['plan']);
    paymentList = List.from(json['paymentList']).map((e) => PaymentList.fromJson(e)).toList();
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `plan`: a map representing the plan, as returned by `Plan.toJson()`
  /// - `paymentList`: a list of maps representing the payments, as returned by `PaymentList.toJson()`

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['plan'] = plan.toJson();
    data['paymentList'] = paymentList.map((e) => e.toJson()).toList();
    return data;
  }
}

class Plan {
  Plan({
    required this.id,
    required this.title,
    required this.charge,
    required this.type,
    required this.chargeFrequency,
    this.stripeProductId,
    this.stripeProductPriceId,
    required this.description,
    required this.features,
  });
  late final int id;
  late final String title;
  late final int charge;
  late final String type;
  late final int chargeFrequency;
  late final String? stripeProductId;
  late final String? stripeProductPriceId;
  late final String description;
  late final List<String> features;

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    charge = json['charge'];
    type = json['type'];
    chargeFrequency = json['chargeFrequency'];
    stripeProductId = json['stripeProductId'];
    stripeProductPriceId = json['stripeProductPriceId'];
    description = json['description'];
    features = List.castFrom<dynamic, String>(json['features']);
  }

  /// Converts the `Plan` instance to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the plan ID
  /// - `title`: the plan title
  /// - `charge`: the plan charge
  /// - `type`: the plan type
  /// - `chargeFrequency`: the plan charge frequency
  /// - `stripeProductId`: the Stripe product ID
  /// - `stripeProductPriceId`: the Stripe product price ID
  /// - `description`: the plan description
  /// - `features`: a list of strings representing the plan features
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['charge'] = charge;
    data['type'] = type;
    data['chargeFrequency'] = chargeFrequency;
    data['stripeProductId'] = stripeProductId;
    data['stripeProductPriceId'] = stripeProductPriceId;
    data['description'] = description;
    data['features'] = features;
    return data;
  }
}

class PaymentList {
  PaymentList({
    required this.id,
    required this.userId,
    required this.start,
    required this.ends,
    required this.charge,
    required this.discount,
    required this.plan,
    required this.startEnd,
    required this.added,
  });
  late final int id;
  late final int userId;
  late final int start;
  late final int ends;
  late final int charge;
  late final int discount;
  late final Plan plan;
  late final String startEnd;
  late final String added;

  PaymentList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    start = json['start'];
    ends = json['ends'];
    charge = json['charge'];
    discount = json['discount'];
    plan = Plan.fromJson(json['plan']);
    startEnd = json['startEnd'];
    added = json['added'];
  }

  /// Converts the `PaymentList` instance to a json-like map.
  ///
  /// The map will contain the following keys:
  /// - `id`: the payment list ID
  /// - `userId`: the user ID associated with the payment
  /// - `start`: the start timestamp of the payment period
  /// - `ends`: the end timestamp of the payment period
  /// - `charge`: the charge amount for the payment
  /// - `discount`: the discount applied to the payment
  /// - `plan`: a map representing the plan details, as returned by `Plan.toJson()`
  /// - `startEnd`: a string representing the start and end of the payment period
  /// - `added`: a string indicating when the payment was added

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['start'] = start;
    data['ends'] = ends;
    data['charge'] = charge;
    data['discount'] = discount;
    data['plan'] = plan.toJson();
    data['startEnd'] = startEnd;
    data['added'] = added;
    return data;
  }
}
