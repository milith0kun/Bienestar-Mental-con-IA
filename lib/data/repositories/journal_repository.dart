import '../../core/config/api_config.dart';
import '../datasources/api_client.dart';
import '../models/journal_entry_model.dart';

class JournalRepository {
  final ApiClient _apiClient;

  JournalRepository(this._apiClient);

  /// Crear nueva entrada de diario
  Future<JournalEntryModel> createEntry({
    required String title,
    required String content,
    required String mood,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.journal}/entries',
        data: {
          'title': title,
          'content': content,
          'mood': mood,
        },
      );

      if (response.data['success'] == true) {
        return JournalEntryModel.fromJson(response.data['data']['entry']);
      }

      throw Exception(response.data['message'] ?? 'Error al crear entrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener entradas de diario
  Future<List<JournalEntryModel>> getEntries({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.journal}/entries',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        final entries = (response.data['data']['entries'] as List)
            .map((entry) => JournalEntryModel.fromJson(entry))
            .toList();
        return entries;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener una entrada específica
  Future<JournalEntryModel> getEntry(String id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.journal}/entries/$id');

      if (response.data['success'] == true) {
        return JournalEntryModel.fromJson(response.data['data']['entry']);
      }

      throw Exception(response.data['message'] ?? 'Entrada no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar entrada de diario
  Future<JournalEntryModel> updateEntry({
    required String id,
    String? title,
    String? content,
    String? mood,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (mood != null) data['mood'] = mood;

      final response = await _apiClient.put(
        '${ApiConfig.journal}/entries/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        return JournalEntryModel.fromJson(response.data['data']['entry']);
      }

      throw Exception(response.data['message'] ?? 'Error al actualizar entrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar entrada de diario
  Future<bool> deleteEntry(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConfig.journal}/entries/$id');

      return response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas de diario
  Future<JournalStatsModel> getStats() async {
    try {
      final response = await _apiClient.get('${ApiConfig.journal}/stats');

      if (response.data['success'] == true) {
        return JournalStatsModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
    } catch (e) {
      rethrow;
    }
  }
}
