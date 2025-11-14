import '../../core/config/api_config.dart';
import '../datasources/api_client.dart';
import '../models/meditation_model.dart';

class MeditationRepository {
  final ApiClient _apiClient;

  MeditationRepository(this._apiClient);

  /// Obtener lista de meditaciones
  Future<List<MeditationModel>> getMeditations({
    String? category,
    String? difficulty,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.get(
        ApiConfig.meditations,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final meditations = (response.data['data']['meditations'] as List)
            .map((m) => MeditationModel.fromJson(m))
            .toList();
        return meditations;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener categorías disponibles
  Future<List<MeditationCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('${ApiConfig.meditations}/categories');

      if (response.data['success'] == true) {
        final categories = (response.data['data']['categories'] as List)
            .map((c) => MeditationCategoryModel.fromJson(c))
            .toList();
        return categories;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener meditaciones destacadas
  Future<List<MeditationModel>> getFeaturedMeditations() async {
    try {
      final response = await _apiClient.get('${ApiConfig.meditations}/featured');

      if (response.data['success'] == true) {
        final meditations = (response.data['data']['meditations'] as List)
            .map((m) => MeditationModel.fromJson(m))
            .toList();
        return meditations;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de una meditación
  Future<MeditationModel> getMeditation(String id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.meditations}/$id');

      if (response.data['success'] == true) {
        return MeditationModel.fromJson(response.data['data']['meditation']);
      }

      throw Exception(response.data['message'] ?? 'Meditación no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Registrar reproducción de meditación
  Future<String> playMeditation(String id) async {
    try {
      final response = await _apiClient.post('${ApiConfig.meditations}/$id/play');

      if (response.data['success'] == true) {
        return response.data['data']['audioUrl'] ?? '';
      }

      throw Exception(response.data['message'] ?? 'Error al reproducir');
    } catch (e) {
      rethrow;
    }
  }

  /// Marcar meditación como completada
  Future<MeditationCompletionModel> completeMeditation({
    required String id,
    int? duration,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.meditations}/$id/complete',
        data: {
          if (duration != null) 'duration': duration,
        },
      );

      if (response.data['success'] == true) {
        return MeditationCompletionModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al completar');
    } catch (e) {
      rethrow;
    }
  }

  /// Calificar meditación
  Future<bool> rateMeditation({
    required String id,
    required int rating,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.meditations}/$id/rate',
        data: {'rating': rating},
      );

      return response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
