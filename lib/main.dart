/// ====================================================================
/// Forward AI — Main Application Entry Point
/// ====================================================================
/// This is the root of the Forward AI Flutter application.
///
/// Responsibilities:
///   1. Initialize the Flutter framework
///   2. Set up dependency injection via Provider
///   3. Configure the app theme (Material Design 3)
///   4. Define the navigation root (HomeScreen)
///
/// Architecture Overview:
///   - State Management: Provider (ChangeNotifier pattern)
///   - Navigation: Standard Navigator with custom transitions
///   - Theme: Centralized dark theme (see config/theme.dart)
///   - Layers: Models → Services → Providers → Screens
///
/// Author:  Forward AI Team
/// Version: 1.0.0 (Hackathon MVP)
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/analysis_provider.dart';
import 'screens/home_screen.dart';

/// Application entry point.
///
/// Calls [runApp] with our root widget wrapped in Provider setup.
void main() {
  // Ensure Flutter bindings are initialized before any platform calls.
  // This is required when calling platform-specific code before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Set the system UI overlay style for a polished look.
  // Makes the status bar transparent to match our gradient background.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait mode for consistent UI
  // (can be removed if landscape support is needed later)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the application
  runApp(const ForwardAIApp());
}

/// Root widget of the Forward AI application.
///
/// Sets up:
///   - [MultiProvider] for dependency injection of all providers
///   - [MaterialApp] with our custom dark theme
///   - [HomeScreen] as the initial route
///
/// Using [MultiProvider] at the root ensures all providers are accessible
/// anywhere in the widget tree. This is the recommended approach for
/// app-wide state in Flutter with Provider.
class ForwardAIApp extends StatelessWidget {
  const ForwardAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // --- Provider Registration ---
      // All providers are created here and available to the entire widget tree.
      // Add new providers here as the app grows (e.g., AuthProvider, ThemeProvider).
      providers: [
        // AnalysisProvider: Manages the career analysis state machine.
        // Using ChangeNotifierProvider creates the provider lazily and
        // automatically disposes it when the widget tree is torn down.
        ChangeNotifierProvider(
          create: (_) => AnalysisProvider(),
        ),
      ],

      // --- Material App ---
      child: MaterialApp(
        // App identity
        title: 'Forward AI',
        debugShowCheckedModeBanner: false,

        // Theme configuration (see config/theme.dart)
        theme: AppTheme.darkTheme,

        // Initial screen
        home: const HomeScreen(),
      ),
    );
  }
}
