import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/meditation/meditation_list_screen.dart';
import '../../presentation/screens/meditation/meditation_detail_screen.dart';
import '../../presentation/screens/journal/journal_list_screen.dart';
import '../../presentation/screens/journal/journal_edit_screen.dart';
import '../../presentation/screens/mood/mood_log_screen.dart';
import '../../presentation/screens/mood/mood_history_screen.dart';
import '../../presentation/screens/subscription/subscription_screen.dart';
import '../../presentation/screens/settings/notifications_screen.dart';

class RouterConfig {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final authStatus = authProvider.status;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToOnboarding = state.matchedLocation == '/onboarding';
        final isGoingToSplash = state.matchedLocation == '/';
        final isGoingToForgotPassword = state.matchedLocation == '/forgot-password';

        // Si está cargando, mostrar splash
        if (authStatus == AuthStatus.initial) {
          return isGoingToSplash ? null : '/';
        }

        // Si está autenticado
        if (authStatus == AuthStatus.authenticated) {
          // Si intenta ir a auth screens, redirigir a home
          if (isGoingToLogin ||
              isGoingToRegister ||
              isGoingToOnboarding ||
              isGoingToSplash ||
              isGoingToForgotPassword) {
            return '/home';
          }
          return null;
        }

        // Si no está autenticado
        if (authStatus == AuthStatus.unauthenticated) {
          // Permitir acceso a auth screens
          if (isGoingToLogin ||
              isGoingToRegister ||
              isGoingToOnboarding ||
              isGoingToForgotPassword) {
            return null;
          }
          // Redirigir a onboarding para cualquier otra ruta
          return '/onboarding';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // Meditation routes
        GoRoute(
          path: '/meditations',
          name: 'meditations',
          builder: (context, state) => const MeditationListScreen(),
        ),
        GoRoute(
          path: '/meditation-detail',
          name: 'meditationDetail',
          builder: (context, state) {
            final meditationId = state.uri.queryParameters['id'] ?? '';
            return MeditationDetailScreen(meditationId: meditationId);
          },
        ),

        // Journal routes
        GoRoute(
          path: '/journal',
          name: 'journal',
          builder: (context, state) => const JournalListScreen(),
        ),
        GoRoute(
          path: '/journal-create',
          name: 'journalCreate',
          builder: (context, state) => const JournalEditScreen(),
        ),
        GoRoute(
          path: '/journal-edit',
          name: 'journalEdit',
          builder: (context, state) {
            final entryId = state.uri.queryParameters['id'];
            return JournalEditScreen(entryId: entryId);
          },
        ),
        GoRoute(
          path: '/journal-detail',
          name: 'journalDetail',
          builder: (context, state) {
            final entryId = state.uri.queryParameters['id'];
            return JournalEditScreen(entryId: entryId);
          },
        ),

        // Mood routes
        GoRoute(
          path: '/mood-log',
          name: 'moodLog',
          builder: (context, state) => const MoodLogScreen(),
        ),
        GoRoute(
          path: '/mood-history',
          name: 'moodHistory',
          builder: (context, state) => const MoodHistoryScreen(),
        ),

        // Subscription routes
        GoRoute(
          path: '/subscription',
          name: 'subscription',
          builder: (context, state) => const SubscriptionScreen(),
        ),

        // Settings routes
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.matchedLocation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
