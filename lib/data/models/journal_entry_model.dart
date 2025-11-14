class JournalEntryModel {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final String mood; // 'very-bad', 'bad', 'neutral', 'good', 'very-good'
  final AIAnalysis? aiAnalysis;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JournalEntryModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    this.aiAnalysis,
    this.createdAt,
    this.updatedAt,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mood: json['mood'] ?? 'neutral',
      aiAnalysis: json['aiAnalysis'] != null
          ? AIAnalysis.fromJson(json['aiAnalysis'])
          : null,
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
      'title': title,
      'content': content,
      'mood': mood,
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class AIAnalysis {
  final String status; // 'pending', 'processing', 'completed', 'error'
  final Sentiment? sentiment;
  final List<String> themes;
  final String? insights;
  final DateTime? processedAt;
  final String? error;

  AIAnalysis({
    required this.status,
    this.sentiment,
    this.themes = const [],
    this.insights,
    this.processedAt,
    this.error,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      status: json['status'] ?? 'pending',
      sentiment: json['sentiment'] != null
          ? Sentiment.fromJson(json['sentiment'])
          : null,
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      insights: json['insights'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (sentiment != null) 'sentiment': sentiment!.toJson(),
      'themes': themes,
      if (insights != null) 'insights': insights,
      if (processedAt != null) 'processedAt': processedAt!.toIso8601String(),
      if (error != null) 'error': error,
    };
  }
}

class Sentiment {
  final String overall; // 'negative', 'neutral', 'positive'
  final double score; // -1 to 1

  Sentiment({
    required this.overall,
    required this.score,
  });

  factory Sentiment.fromJson(Map<String, dynamic> json) {
    return Sentiment(
      overall: json['overall'] ?? 'neutral',
      score: (json['score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'score': score,
    };
  }
}

class JournalStatsModel {
  final int totalEntries;
  final int entriesThisMonth;
  final bool canCreateMore;
  final dynamic remaining; // int or 'unlimited'
  final bool isPremium;
  final List<MoodDistribution> moodDistribution;
  final List<ThemeCount> topThemes;

  JournalStatsModel({
    required this.totalEntries,
    required this.entriesThisMonth,
    required this.canCreateMore,
    this.remaining,
    required this.isPremium,
    this.moodDistribution = const [],
    this.topThemes = const [],
  });

  factory JournalStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return JournalStatsModel(
      totalEntries: stats['totalEntries'] ?? 0,
      entriesThisMonth: stats['entriesThisMonth'] ?? 0,
      canCreateMore: stats['canCreateMore'] ?? false,
      remaining: stats['remaining'],
      isPremium: stats['isPremium'] ?? false,
      moodDistribution: (json['moodDistribution'] as List<dynamic>?)
              ?.map((e) => MoodDistribution.fromJson(e))
              .toList() ??
          [],
      topThemes: (json['topThemes'] as List<dynamic>?)
              ?.map((e) => ThemeCount.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MoodDistribution {
  final String mood;
  final int count;

  MoodDistribution({
    required this.mood,
    required this.count,
  });

  factory MoodDistribution.fromJson(Map<String, dynamic> json) {
    return MoodDistribution(
      mood: json['_id'] ?? json['mood'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ThemeCount {
  final String theme;
  final int count;

  ThemeCount({
    required this.theme,
    required this.count,
  });

  factory ThemeCount.fromJson(Map<String, dynamic> json) {
    return ThemeCount(
      theme: json['theme'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
