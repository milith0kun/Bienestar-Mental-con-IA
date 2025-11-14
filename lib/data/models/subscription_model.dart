class SubscriptionModel {
  final String plan; // 'free', 'premium'
  final String status; // 'active', 'canceled', 'past_due', 'trialing'
  final bool isPremium;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, bool> features;

  SubscriptionModel({
    required this.plan,
    required this.status,
    required this.isPremium,
    this.startDate,
    this.endDate,
    this.features = const {},
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>? ?? {};
    final features = json['features'] as Map<String, dynamic>? ?? {};

    return SubscriptionModel(
      plan: subscription['plan'] ?? 'free',
      status: subscription['status'] ?? 'active',
      isPremium: subscription['isPremium'] ?? false,
      startDate: subscription['startDate'] != null
          ? DateTime.parse(subscription['startDate'])
          : null,
      endDate: subscription['endDate'] != null
          ? DateTime.parse(subscription['endDate'])
          : null,
      features: features.map((key, value) => MapEntry(key, value as bool)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'isPremium': isPremium,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'features': features,
    };
  }

  bool hasFeature(String featureName) {
    return features[featureName] ?? false;
  }
}

class PlanFeaturesModel {
  final PlanDetails free;
  final PlanDetails premium;

  PlanFeaturesModel({
    required this.free,
    required this.premium,
  });

  factory PlanFeaturesModel.fromJson(Map<String, dynamic> json) {
    final plans = json['plans'] as Map<String, dynamic>? ?? {};

    return PlanFeaturesModel(
      free: PlanDetails.fromJson(plans['free'] ?? {}),
      premium: PlanDetails.fromJson(plans['premium'] ?? {}),
    );
  }
}

class PlanDetails {
  final String name;
  final double price;
  final String? currency;
  final String? period;
  final List<String> features;

  PlanDetails({
    required this.name,
    required this.price,
    this.currency,
    this.period,
    this.features = const [],
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'],
      period: json['period'],
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get priceFormatted {
    if (price == 0) return 'Gratis';
    if (currency != null && period != null) {
      return '\$$price $currency/$period';
    }
    return '\$$price';
  }
}
