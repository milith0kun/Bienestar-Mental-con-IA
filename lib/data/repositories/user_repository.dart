import '../../core/config/api_config.dart';
import '../datasources/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  // Obtener perfil del usuario
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get('${ApiConfig.users}/profile');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!['user']);
      }

      throw Exception(apiResponse.message);
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar perfil
  Future<UserModel> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (profilePicture != null) data['profilePicture'] = profilePicture;

      final response = await _apiClient.put(
        '${ApiConfig.users}/profile',
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!['user']);
      }

      throw Exception(apiResponse.message);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener estadísticas
  Future<StatsModel> getStats() async {
    try {
      final response = await _apiClient.get('${ApiConfig.users}/stats');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return StatsModel.fromJson(apiResponse.data!['stats']);
      }

      throw Exception(apiResponse.message);
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar preferencias
  Future<PreferencesModel> updatePreferences({
    bool? notificationsEnabled,
    Map<String, dynamic>? meditationReminder,
    Map<String, dynamic>? moodReminder,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (notificationsEnabled != null) {
        data['notificationsEnabled'] = notificationsEnabled;
      }
      if (meditationReminder != null) {
        data['meditationReminder'] = meditationReminder;
      }
      if (moodReminder != null) {
        data['moodReminder'] = moodReminder;
      }

      final response = await _apiClient.put(
        '${ApiConfig.users}/preferences',
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PreferencesModel.fromJson(apiResponse.data!['preferences']);
      }

      throw Exception(apiResponse.message);
    } catch (e) {
      rethrow;
    }
  }

  // Agregar token FCM
  Future<void> addFcmToken(String token) async {
    try {
      await _apiClient.post(
        '${ApiConfig.users}/fcm-token',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar token FCM
  Future<void> removeFcmToken(String token) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.users}/fcm-token',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('${ApiConfig.users}/account');
    } catch (e) {
      rethrow;
    }
  }
}
