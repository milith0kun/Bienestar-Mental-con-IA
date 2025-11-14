import 'package:flutter/material.dart';
import '../../data/datasources/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthProvider({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? AuthRepository(ApiClient()),
        _userRepository = userRepository ?? UserRepository(ApiClient());

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Inicializar - Verificar si hay sesión activa
  Future<void> init() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();

      if (isAuth) {
        // Obtener perfil del usuario
        await loadUserProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Registrar usuario
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );

      if (response.success) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.success) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión con Google
  Future<bool> loginWithGoogle(String idToken) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _authRepository.loginWithGoogle(idToken);

      if (response.success) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      _error = null;
      notifyListeners();

      final success = await _authRepository.forgotPassword(email);
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _authRepository.resetPassword(
        token: token,
        password: password,
      );

      if (response.success) {
        // Después de resetear, cargar el perfil
        await loadUserProfile();
        return true;
      } else {
        _error = response.message;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Cargar perfil del usuario
  Future<void> loadUserProfile() async {
    try {
      _user = await _userRepository.getProfile();
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    try {
      _error = null;

      final updatedUser = await _userRepository.updateProfile(
        name: name,
        profilePicture: profilePicture,
      );

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Actualizar preferencias
  Future<bool> updatePreferences({
    bool? notificationsEnabled,
    Map<String, dynamic>? meditationReminder,
    Map<String, dynamic>? moodReminder,
  }) async {
    try {
      _error = null;

      final updatedPreferences = await _userRepository.updatePreferences(
        notificationsEnabled: notificationsEnabled,
        meditationReminder: meditationReminder,
        moodReminder: moodReminder,
      );

      if (_user != null) {
        _user = _user!.copyWith(preferences: updatedPreferences);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
