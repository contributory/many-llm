import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/chat_page.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'theme.dart';

/// **Application Entry Point**
///
/// Sets up the provider structure and MaterialApp configuration for the AI Chat Template.
/// This structure enables reactive state management and theme switching throughout the app.
///
/// ## Provider Architecture:
/// - `ChatProvider`: Manages conversations, messages, and AI interactions
/// - `ThemeProvider`: Handles theme state (system/light/dark switching)
///
/// ## Theme Integration:
/// - Uses custom `lightTheme` and `darkTheme` from theme.dart
/// - Defaults to `ThemeMode.system` for platform-appropriate theming
/// - Theme switching via `ThemeProvider.toggleThemeMode()`
///
/// ## Extension Examples:
/// ```dart
/// // Add additional providers:
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => ChatProvider()),
///     ChangeNotifierProvider(create: (_) => ThemeProvider()),
///     ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
///     ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
///   ],
///   child: AiChatApp(),
/// )
///
/// // Add routing:
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
///   theme: lightTheme,
///   darkTheme: darkTheme,
/// )
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AiChatApp());
}

class AiChatApp extends StatelessWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (context, settingsProvider, chatProvider) {
            chatProvider!.setSettingsProvider(settingsProvider);
            return chatProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Chat',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const ChatPage(),
          );
        },
      ),
    );
  }
}
