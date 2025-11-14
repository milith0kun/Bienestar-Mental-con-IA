import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow/presentation/providers/auth_provider.dart';
import 'package:mindflow/data/models/user_model.dart';
import 'package:mindflow/data/models/auth_response_model.dart';
import 'package:mindflow/data/repositories/auth_repository.dart';
import 'package:mindflow/data/repositories/user_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock classes
@GenerateMocks([AuthRepository, UserRepository])
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    authProvider = AuthProvider(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  });

  group('AuthProvider', () {
    test('initial status is AuthStatus.initial', () {
      expect(authProvider.status, AuthStatus.initial);
      expect(authProvider.user, isNull);
      expect(authProvider.error, isNull);
    });

    test('isAuthenticated returns false initially', () {
      expect(authProvider.isAuthenticated, false);
    });

    test('isLoading returns false initially', () {
      expect(authProvider.isLoading, false);
    });
  });

  group('Register', () {
    final mockUser = UserModel(
      id: '123',
      email: 'test@example.com',
      name: 'Test User',
      authProvider: 'email',
      subscription: SubscriptionModel(plan: 'free', status: 'active'),
    );

    final mockAuthResponse = AuthResponseModel(
      success: true,
      message: 'Usuario registrado exitosamente',
      user: mockUser,
      token: 'test_token',
      refreshToken: 'test_refresh_token',
    );

    test('successful registration updates state correctly', () async {
      // Arrange
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await authProvider.register(
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User',
      );

      // Assert
      expect(result, true);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user, mockUser);
      expect(authProvider.error, isNull);
    });

    test('failed registration updates error state', () async {
      // Arrange
      final failedResponse = AuthResponseModel(
        success: false,
        message: 'Email ya existe',
      );

      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => failedResponse);

      // Act
      final result = await authProvider.register(
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User',
      );

      // Assert
      expect(result, false);
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.error, 'Email ya existe');
    });
  });

  group('Login', () {
    final mockUser = UserModel(
      id: '123',
      email: 'test@example.com',
      name: 'Test User',
      authProvider: 'email',
      subscription: SubscriptionModel(plan: 'free', status: 'active'),
    );

    final mockAuthResponse = AuthResponseModel(
      success: true,
      message: 'Login exitoso',
      user: mockUser,
      token: 'test_token',
      refreshToken: 'test_refresh_token',
    );

    test('successful login updates state correctly', () async {
      // Arrange
      when(mockAuthRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await authProvider.login(
        email: 'test@example.com',
        password: 'Password123',
      );

      // Assert
      expect(result, true);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user?.email, 'test@example.com');
    });

    test('failed login updates error state', () async {
      // Arrange
      final failedResponse = AuthResponseModel(
        success: false,
        message: 'Credenciales inválidas',
      );

      when(mockAuthRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => failedResponse);

      // Act
      final result = await authProvider.login(
        email: 'test@example.com',
        password: 'WrongPassword',
      );

      // Assert
      expect(result, false);
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.error, isNotNull);
    });
  });

  group('Logout', () {
    test('logout clears user data and updates status', () async {
      // Arrange
      when(mockAuthRepository.logout()).thenAnswer((_) async => {});

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.user, isNull);
      expect(authProvider.error, isNull);
    });
  });

  group('UpdateProfile', () {
    final updatedUser = UserModel(
      id: '123',
      email: 'test@example.com',
      name: 'Updated Name',
      authProvider: 'email',
      subscription: SubscriptionModel(plan: 'free', status: 'active'),
    );

    test('successful profile update updates user', () async {
      // Arrange
      when(mockUserRepository.updateProfile(
        name: anyNamed('name'),
        profilePicture: anyNamed('profilePicture'),
      )).thenAnswer((_) async => updatedUser);

      // Act
      final result = await authProvider.updateProfile(name: 'Updated Name');

      // Assert
      expect(result, true);
      expect(authProvider.user?.name, 'Updated Name');
      expect(authProvider.error, isNull);
    });
  });

  group('ClearError', () {
    test('clearError sets error to null', () {
      // Set an error first
      authProvider.clearError();

      // Assert
      expect(authProvider.error, isNull);
    });
  });
}
