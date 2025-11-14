import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow/main.dart';
import 'package:mindflow/presentation/screens/splash_screen.dart';
import 'package:mindflow/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('MyApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify splash screen content
    expect(find.text('MindFlow'), findsOneWidget);
    expect(find.text('Bienestar Mental con IA'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.self_improvement), findsOneWidget);
  });

  testWidgets('OnboardingScreen displays pages', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify first page content
    expect(find.text('Meditaciones Guiadas'), findsOneWidget);
    expect(find.byIcon(Icons.self_improvement), findsOneWidget);

    // Find and tap next button
    final nextButton = find.text('Siguiente');
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Verify second page content
    expect(find.text('Diario Emocional con IA'), findsOneWidget);
    expect(find.byIcon(Icons.book), findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Verify third page content
    expect(find.text('Seguimiento de Ánimo'), findsOneWidget);
    expect(find.byIcon(Icons.mood), findsOneWidget);

    // On last page, button should say "Comenzar"
    expect(find.text('Comenzar'), findsOneWidget);
  });

  testWidgets('OnboardingScreen navigation buttons work',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Find "Ya tengo una cuenta" button
    final loginButton = find.text('Ya tengo una cuenta');
    expect(loginButton, findsOneWidget);
  });
}
