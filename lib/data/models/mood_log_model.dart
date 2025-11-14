class MoodLogModel {
  final String? id;
  final String userId;
  final DateTime date;
  final int mood; // 1-10
  final List<String> emotions;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MoodLogModel({
    this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.emotions = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory MoodLogModel.fromJson(Map<String, dynamic> json) {
    return MoodLogModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      date: DateTime.parse(json['date']),
      mood: json['mood'] ?? 5,
      emotions: (json['emotions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'emotions': emotions,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  MoodLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? mood,
    List<String>? emotions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      emotions: emotions ?? this.emotions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MoodStatsModel {
  final double? averageMood;
  final String trend; // 'improving', 'declining', 'stable'
  final int totalLogs;
  final List<EmotionCount> topEmotions;
  final List<MoodLogModel> logs;

  MoodStatsModel({
    this.averageMood,
    required this.trend,
    required this.totalLogs,
    this.topEmotions = const [],
    this.logs = const [],
  });

  factory MoodStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return MoodStatsModel(
      averageMood: stats['averageMood']?.toDouble(),
      trend: stats['trend'] ?? 'stable',
      totalLogs: stats['totalLogs'] ?? 0,
      topEmotions: (stats['topEmotions'] as List<dynamic>?)
              ?.map((e) => EmotionCount.fromJson(e))
              .toList() ??
          [],
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => MoodLogModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EmotionCount {
  final String emotion;
  final int count;

  EmotionCount({
    required this.emotion,
    required this.count,
  });

  factory EmotionCount.fromJson(Map<String, dynamic> json) {
    return EmotionCount(
      emotion: json['emotion'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
