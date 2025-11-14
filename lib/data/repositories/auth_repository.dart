import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  // Registrar nuevo usuario
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.auth}/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        await _saveAuthData(
          authResponse.token!,
          authResponse.refreshToken!,
          authResponse.user!,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con email
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.auth}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        await _saveAuthData(
          authResponse.token!,
          authResponse.refreshToken!,
          authResponse.user!,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con Google
  Future<AuthResponseModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.auth}/google',
        data: {
          'idToken': idToken,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        await _saveAuthData(
          authResponse.token!,
          authResponse.refreshToken!,
          authResponse.user!,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.auth}/forgot-password',
        data: {
          'email': email,
        },
      );

      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<AuthResponseModel> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.auth}/reset-password',
        data: {
          'token': token,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        await _saveAuthTokens(
          authResponse.token!,
          authResponse.refreshToken!,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyAccessToken);
      await prefs.remove(AppConstants.keyRefreshToken);
      await prefs.remove(AppConstants.keyUserId);
      await prefs.remove(AppConstants.keyUserEmail);
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    } catch (e) {
      rethrow;
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAccessToken);
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      return token != null && isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  // Obtener token de acceso
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyAccessToken);
    } catch (e) {
      return null;
    }
  }

  // Guardar datos de autenticación
  Future<void> _saveAuthData(
    String token,
    String refreshToken,
    UserModel user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, token);
    await prefs.setString(AppConstants.keyRefreshToken, refreshToken);
    await prefs.setString(AppConstants.keyUserId, user.id);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  // Guardar solo tokens (para reset password)
  Future<void> _saveAuthTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, token);
    await prefs.setString(AppConstants.keyRefreshToken, refreshToken);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }
}
