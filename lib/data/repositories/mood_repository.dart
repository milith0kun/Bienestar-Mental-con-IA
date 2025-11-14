import '../../core/config/api_config.dart';
import '../datasources/api_client.dart';
import '../models/mood_log_model.dart';

class MoodRepository {
  final ApiClient _apiClient;

  MoodRepository(this._apiClient);

  /// Crear o actualizar registro de estado de ánimo
  Future<MoodLogModel> createMoodLog({
    required int mood,
    List<String>? emotions,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.mood}/logs',
        data: {
          'mood': mood,
          if (emotions != null) 'emotions': emotions,
          if (notes != null) 'notes': notes,
          if (date != null) 'date': date.toIso8601String(),
        },
      );

      if (response.data['success'] == true) {
        return MoodLogModel.fromJson(response.data['data']['moodLog']);
      }

      throw Exception(response.data['message'] ?? 'Error al crear registro');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener registros de estado de ánimo
  Future<List<MoodLogModel>> getMoodLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '${ApiConfig.mood}/logs',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final logs = (response.data['data']['logs'] as List)
            .map((log) => MoodLogModel.fromJson(log))
            .toList();
        return logs;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas de estado de ánimo
  Future<MoodStatsModel> getMoodStats({int days = 7}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.mood}/stats',
        queryParameters: {'days': days},
      );

      if (response.data['success'] == true) {
        return MoodStatsModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener registro de hoy
  Future<MoodLogModel?> getTodayMood() async {
    try {
      final response = await _apiClient.get('${ApiConfig.mood}/today');

      if (response.data['success'] == true) {
        final moodLog = response.data['data']['moodLog'];
        if (moodLog != null) {
          return MoodLogModel.fromJson(moodLog);
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar registro de estado de ánimo
  Future<bool> deleteMoodLog(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConfig.mood}/logs/$id');

      return response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
