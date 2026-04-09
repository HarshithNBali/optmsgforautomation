class PlanListModel {
  PlanListModel({
    required this.success,
    required this.data,
    required this.message,
  });
  late final bool success;
  late final Data data;
  late final String message;

  PlanListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  /// Converts the `PlanListModel` instance to a json-like map.
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
    required this.plans,
  });
  late final List<Plans> plans;

  Data.fromJson(Map<String, dynamic> json) {
    plans = List.from(json['plans']).map((e) => Plans.fromJson(e)).toList();
  }

  /// Converts the `Data` instance to a json-like map.
  ///
  /// The resulting map will contain a single key, `plans`, which is a list of maps
  /// representing the plans in the response, as returned by `Plans.toJson()`.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['plans'] = plans.map((e) => e.toJson()).toList();
    return data;
  }
}

class Plans {
  Plans({
    required this.id,
    required this.title,
    required this.charge,
    required this.type,
    required this.chargeFrequency,
    this.stripeProductId,
    this.stripeProductPriceId,
    required this.description,
    required this.features,
    required this.nextPaymentDate,
  });
  late final int id;
  late final String title;
  late final dynamic charge;
  late final String type;
  late final int chargeFrequency;
  late final String? stripeProductId;
  late final String? stripeProductPriceId;
  late final String description;
  late final List<String> features;
  late final String nextPaymentDate;

  Plans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    charge = json['charge'];
    type = json['type'];
    chargeFrequency = json['chargeFrequency'];
    stripeProductId = json['stripeProductId'];
    stripeProductPriceId = json['stripeProductPriceId'];
    description = json['description'];
    features = List.castFrom<dynamic, String>(json['features']);
    nextPaymentDate = json['nextPaymentDate'] ?? '';
  }

  /// Converts the `Plans` instance to a json-like map.
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
  /// - `nextPaymentDate`: the next payment date for the plan

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
    data['nextPaymentDate'] = nextPaymentDate;
    return data;
  }
}
