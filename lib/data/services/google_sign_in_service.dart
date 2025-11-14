import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleSignInService {
  final Logger _logger = Logger();

  // Configurar Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Iniciar sesión con Google
  Future<String?> signIn() async {
    try {
      // Intentar signin silencioso primero
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      // Si no funciona, mostrar UI
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        _logger.w('Google Sign In cancelado por el usuario');
        return null;
      }

      // Obtener authentication
      final GoogleSignInAuthentication auth = await account.authentication;

      // Retornar el ID token
      return auth.idToken;
    } catch (error) {
      _logger.e('Error en Google Sign In: $error');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      _logger.e('Error al cerrar sesión de Google: $error');
      rethrow;
    }
  }

  // Desconectar cuenta
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      _logger.e('Error al desconectar Google: $error');
      rethrow;
    }
  }

  // Verificar si está autenticado
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Obtener cuenta actual
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
  }
}
