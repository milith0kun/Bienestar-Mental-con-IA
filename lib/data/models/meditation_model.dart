class MeditationModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final int duration; // en segundos
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String audioUrl;
  final String? thumbnailUrl;
  final bool isPremium;
  final List<String> tags;
  final String instructor;
  final int plays;
  final double averageRating;
  final int ratingsCount;
  final bool isActive;
  final bool? hasAccess;
  final bool? requiresPremium;

  MeditationModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.audioUrl,
    this.thumbnailUrl,
    this.isPremium = false,
    this.tags = const [],
    this.instructor = 'MindFlow',
    this.plays = 0,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.isActive = true,
    this.hasAccess,
    this.requiresPremium,
  });

  factory MeditationModel.fromJson(Map<String, dynamic> json) {
    return MeditationModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      duration: json['duration'] ?? 0,
      difficulty: json['difficulty'] ?? 'beginner',
      audioUrl: json['audioUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      isPremium: json['isPremium'] ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      instructor: json['instructor'] ?? 'MindFlow',
      plays: json['plays'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      hasAccess: json['hasAccess'],
      requiresPremium: json['requiresPremium'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'difficulty': difficulty,
      'audioUrl': audioUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'isPremium': isPremium,
      'tags': tags,
      'instructor': instructor,
      'plays': plays,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'isActive': isActive,
      if (hasAccess != null) 'hasAccess': hasAccess,
      if (requiresPremium != null) 'requiresPremium': requiresPremium,
    };
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get categoryName {
    final categories = {
      'anxiety': 'Ansiedad',
      'stress': 'Estrés',
      'sleep': 'Sueño',
      'focus': 'Enfoque',
      'self-esteem': 'Autoestima',
      'gratitude': 'Gratitud',
      'general': 'Bienestar General',
    };
    return categories[category] ?? category;
  }

  String get difficultyName {
    final difficulties = {
      'beginner': 'Principiante',
      'intermediate': 'Intermedio',
      'advanced': 'Avanzado',
    };
    return difficulties[difficulty] ?? difficulty;
  }
}

class MeditationCategoryModel {
  final String id;
  final String name;
  final int count;
  final int avgDuration;

  MeditationCategoryModel({
    required this.id,
    required this.name,
    required this.count,
    required this.avgDuration,
  });

  factory MeditationCategoryModel.fromJson(Map<String, dynamic> json) {
    return MeditationCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      avgDuration: json['avgDuration'] ?? 0,
    );
  }
}

class MeditationCompletionModel {
  final int totalMeditations;
  final int totalMeditationTime;
  final int consecutiveDays;

  MeditationCompletionModel({
    required this.totalMeditations,
    required this.totalMeditationTime,
    required this.consecutiveDays,
  });

  factory MeditationCompletionModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return MeditationCompletionModel(
      totalMeditations: stats['totalMeditations'] ?? 0,
      totalMeditationTime: stats['totalMeditationTime'] ?? 0,
      consecutiveDays: stats['consecutiveDays'] ?? 0,
    );
  }

  String get totalTimeFormatted {
    final hours = totalMeditationTime ~/ 3600;
    final minutes = (totalMeditationTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
