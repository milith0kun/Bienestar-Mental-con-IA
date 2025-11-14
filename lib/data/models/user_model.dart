class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final String authProvider;
  final SubscriptionModel subscription;
  final PreferencesModel? preferences;
  final StatsModel? stats;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.authProvider,
    required this.subscription,
    this.preferences,
    this.stats,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      email: json['email'],
      name: json['name'],
      profilePicture: json['profilePicture'],
      authProvider: json['authProvider'] ?? 'email',
      subscription: SubscriptionModel.fromJson(json['subscription'] ?? {}),
      preferences: json['preferences'] != null
          ? PreferencesModel.fromJson(json['preferences'])
          : null,
      stats: json['stats'] != null ? StatsModel.fromJson(json['stats']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'authProvider': authProvider,
      'subscription': subscription.toJson(),
      'preferences': preferences?.toJson(),
      'stats': stats?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isPremium =>
      subscription.plan == 'premium' && subscription.status == 'active';

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePicture,
    String? authProvider,
    SubscriptionModel? subscription,
    PreferencesModel? preferences,
    StatsModel? stats,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      authProvider: authProvider ?? this.authProvider,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubscriptionModel {
  final String plan;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionModel({
    required this.plan,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] ?? 'free',
      status: json['status'] ?? 'active',
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}

class PreferencesModel {
  final bool notificationsEnabled;
  final ReminderModel meditationReminder;
  final ReminderModel moodReminder;

  PreferencesModel({
    required this.notificationsEnabled,
    required this.meditationReminder,
    required this.moodReminder,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      meditationReminder:
          ReminderModel.fromJson(json['meditationReminder'] ?? {}),
      moodReminder: ReminderModel.fromJson(json['moodReminder'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'meditationReminder': meditationReminder.toJson(),
      'moodReminder': moodReminder.toJson(),
    };
  }
}

class ReminderModel {
  final bool enabled;
  final String time;

  ReminderModel({
    required this.enabled,
    required this.time,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      enabled: json['enabled'] ?? false,
      time: json['time'] ?? '09:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'time': time,
    };
  }
}

class StatsModel {
  final int totalMeditations;
  final int totalMeditationTime;
  final String totalMeditationTimeFormatted;
  final int consecutiveDays;
  final DateTime? lastMeditationDate;
  final int journalEntries;
  final int journalEntriesThisMonth;
  final dynamic journalEntriesRemaining; // Can be int or 'unlimited'

  StatsModel({
    required this.totalMeditations,
    required this.totalMeditationTime,
    required this.totalMeditationTimeFormatted,
    required this.consecutiveDays,
    this.lastMeditationDate,
    required this.journalEntries,
    required this.journalEntriesThisMonth,
    this.journalEntriesRemaining,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      totalMeditations: json['totalMeditations'] ?? 0,
      totalMeditationTime: json['totalMeditationTime'] ?? 0,
      totalMeditationTimeFormatted:
          json['totalMeditationTimeFormatted'] ?? '0m',
      consecutiveDays: json['consecutiveDays'] ?? 0,
      lastMeditationDate: json['lastMeditationDate'] != null
          ? DateTime.parse(json['lastMeditationDate'])
          : null,
      journalEntries: json['journalEntries'] ?? 0,
      journalEntriesThisMonth: json['journalEntriesThisMonth'] ?? 0,
      journalEntriesRemaining: json['journalEntriesRemaining'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMeditations': totalMeditations,
      'totalMeditationTime': totalMeditationTime,
      'totalMeditationTimeFormatted': totalMeditationTimeFormatted,
      'consecutiveDays': consecutiveDays,
      'lastMeditationDate': lastMeditationDate?.toIso8601String(),
      'journalEntries': journalEntries,
      'journalEntriesThisMonth': journalEntriesThisMonth,
      'journalEntriesRemaining': journalEntriesRemaining,
    };
  }
}
