import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/router_config.dart';
import 'core/themes/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/meditation_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/mood_provider.dart';
import 'presentation/providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Continue execution even if .env doesn't exist
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MeditationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => JournalProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'MindFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: RouterConfig.router(authProvider),
          );
        },
      ),
    );
  }
}
