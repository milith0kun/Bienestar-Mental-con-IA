# Guía de Testing - MindFlow

Esta guía explica cómo ejecutar y crear tests para el proyecto MindFlow.

## 📋 Contenido

- [Backend Tests](#backend-tests)
- [Flutter Tests](#flutter-tests)
- [Cobertura de Tests](#cobertura-de-tests)
- [Continuous Integration](#continuous-integration)

## Backend Tests

### Requisitos Previos

```bash
cd backend
npm install
```

### Ejecutar Todos los Tests

```bash
npm test
```

### Ejecutar Tests en Modo Watch

```bash
npm run test:watch
```

### Tests Implementados

#### 1. Auth Tests (`tests/auth.test.js`)
- ✅ Registro de usuario con email
- ✅ Registro con email duplicado (debe fallar)
- ✅ Validación de contraseña débil
- ✅ Validación de email inválido
- ✅ Login con credenciales correctas
- ✅ Login con contraseña incorrecta
- ✅ Login con email no registrado
- ✅ Recuperación de contraseña

#### 2. User Tests (`tests/user.test.js`)
- ✅ Obtener perfil de usuario autenticado
- ✅ Rechazar petición sin token
- ✅ Rechazar petición con token inválido
- ✅ Actualizar nombre de usuario
- ✅ Actualizar foto de perfil
- ✅ Obtener estadísticas
- ✅ Actualizar preferencias
- ✅ Agregar token FCM
- ✅ Eliminar token FCM

#### 3. Model Tests (`tests/models.test.js`)

**User Model:**
- ✅ Crear usuario válido
- ✅ Hashear contraseña antes de guardar
- ✅ Comparar contraseñas correctamente
- ✅ Verificar si usuario es premium
- ✅ Verificar si puede crear entradas de diario
- ✅ Resetear contador mensual de entradas
- ✅ Rechazar email duplicado
- ✅ Rechazar email inválido

**MoodLog Model:**
- ✅ Crear registro de estado de ánimo válido
- ✅ Normalizar fecha al guardar
- ✅ Rechazar valor fuera de rango
- ✅ Calcular promedio de ánimo

**JournalEntry Model:**
- ✅ Crear entrada de diario válida
- ✅ Marcar análisis como en proceso
- ✅ Guardar resultado de análisis
- ✅ Marcar error en análisis
- ✅ Rechazar contenido muy largo

### Configuración de Tests

Los tests usan **MongoDB Memory Server** para crear una base de datos temporal en memoria. Esto permite:
- Tests rápidos sin necesidad de MongoDB instalado
- Aislamiento completo entre tests
- No afecta la base de datos de desarrollo

Configuración en `jest.config.js`:
```javascript
{
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  }
}
```

### Mocks y Stubs

Los servicios externos están mockeados en `tests/setup.js`:
- Email service (nodemailer)
- AWS S3
- OpenAI API

## Flutter Tests

### Requisitos Previos

```bash
flutter pub get
```

### Ejecutar Todos los Tests

```bash
flutter test
```

### Ejecutar Tests con Cobertura

```bash
flutter test --coverage
```

### Ver Reporte de Cobertura

```bash
# Instalar lcov primero
# Linux: sudo apt-get install lcov
# Mac: brew install lcov

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
open coverage/html/index.html
```

### Tests Implementados

#### 1. Widget Tests (`test/widget_test.dart`)
- ✅ MyApp builds successfully
- ✅ SplashScreen muestra contenido correcto
- ✅ OnboardingScreen muestra todas las páginas
- ✅ Navegación entre páginas de onboarding
- ✅ Botones de navegación funcionan

#### 2. Provider Tests (`test/providers/auth_provider_test.dart`)
- ✅ Estado inicial correcto
- ✅ Registro exitoso actualiza estado
- ✅ Registro fallido actualiza error
- ✅ Login exitoso actualiza estado
- ✅ Login fallido actualiza error
- ✅ Logout limpia datos de usuario
- ✅ Actualizar perfil funciona correctamente
- ✅ clearError limpia errores

#### 3. Model Tests (`test/models/user_model_test.dart`)
- ✅ fromJson crea UserModel válido
- ✅ toJson crea JSON válido
- ✅ isPremium funciona correctamente
- ✅ copyWith actualiza valores
- ✅ SubscriptionModel maneja fechas
- ✅ StatsModel maneja entradas ilimitadas

### Configuración de Tests de Flutter

Dependencias necesarias en `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

Para generar mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Cobertura de Tests

### Objetivos de Cobertura

| Componente | Objetivo | Actual |
|-----------|----------|--------|
| Backend   | 70%      | 75%+   |
| Flutter   | 70%      | 70%+   |

### Ver Cobertura del Backend

```bash
cd backend
npm test -- --coverage
```

El reporte se genera en `backend/coverage/lcov-report/index.html`

### Ver Cobertura de Flutter

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Inicializar Base de Datos de Prueba

Para poblar la base de datos con datos de ejemplo:

```bash
cd backend
node scripts/seed.js
```

Esto creará:
- 1 usuario de prueba (test@mindflow.com / Password123)
- 8 meditaciones de ejemplo (5 gratuitas, 3 premium)

## Best Practices

### Backend

1. **Usar MongoDB Memory Server** para tests de integración
2. **Mockear servicios externos** (email, AWS, OpenAI)
3. **Limpiar base de datos** después de cada test
4. **Usar supertest** para tests de endpoints
5. **Verificar códigos de estado HTTP** correctos

Ejemplo:
```javascript
test('debe registrar un nuevo usuario', async () => {
  const response = await request(app)
    .post('/api/v1/auth/register')
    .send({
      name: 'Test User',
      email: 'test@example.com',
      password: 'Password123',
    })
    .expect(201);

  expect(response.body.success).toBe(true);
  expect(response.body.data.user.email).toBe('test@example.com');
});
```

### Flutter

1. **Usar mocks** para repositorios y servicios
2. **Testear providers** de manera aislada
3. **Usar pumpWidget** para widget tests
4. **Verificar estados** correctamente
5. **Usar pumpAndSettle** para animaciones

Ejemplo:
```dart
testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: SplashScreen(),
    ),
  );

  expect(find.text('MindFlow'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Solución de Problemas Comunes

### Backend

**Error: Cannot find module**
```bash
cd backend
npm install
```

**Error: MongoDB connection**
- Los tests usan MongoDB Memory Server
- No necesitas MongoDB instalado
- Si aún falla, limpia node_modules y reinstala

**Tests timeout**
- Aumenta el timeout en jest.config.js
- Verifica que no haya procesos colgados

### Flutter

**Error: No pubspec.yaml**
```bash
flutter pub get
```

**Error: Mocks not generated**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Tests failing on CI**
- Usa `flutter test --no-pub`
- Asegúrate que todas las dependencias estén instaladas

## Continuous Integration

### GitHub Actions

Archivo `.github/workflows/test.yml` (ejemplo):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: cd backend && npm install
      - run: cd backend && npm test

  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
```

## Siguientes Pasos

1. Aumentar cobertura de tests al 80%
2. Agregar tests E2E con Detox/Flutter Driver
3. Implementar tests de performance
4. Agregar tests de accesibilidad
5. Configurar CI/CD pipeline completo

## Recursos

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Supertest](https://github.com/visionmedia/supertest)
