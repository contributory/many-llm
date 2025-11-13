/// **Backend Provider Types** - Defines how the app connects to AI services
///
/// - `direct`: Client-side API calls (development/testing only)
/// - `firebase`: Firebase Functions proxy (recommended for production)
/// - `supabase`: Supabase Edge Functions proxy (alternative for production)
enum BackendProvider { direct, firebase, supabase }

/// **AppConfig** - Central configuration for the AI Chat Template
///
/// This class manages all runtime configuration including API keys, backend selection,
/// and model definitions. It's designed to be environment-aware and secure by default.
///
/// ## Configuration Modes:
///
/// ### 🧪 **Development Mode** (`BackendProvider.direct`)
/// - Client-side API calls for rapid development
/// - API key via `--dart-define` or `testingOnlyOpenRouterApiKey`
/// - Mock responses when no key is provided
/// - ⚠️  Never deploy to web with direct mode
///
/// ### 🚀 **Production Mode** (`BackendProvider.firebase` or `supabase`)
/// - API calls proxied through secure backend
/// - API keys stored safely on server side
/// - Configure proxy URLs below
///
/// ## Security Model:
/// - **Local Dev**: API key in `testingOnlyOpenRouterApiKey` (never commit!)
/// - **CI/Build**: API key via `--dart-define=OPENROUTER_API_KEY=xxx`
/// - **Production**: Backend proxy with server-side API key storage
/// - **Demo Mode**: Mock responses when no key available
///
/// ## Extension Examples:
/// ```dart
/// // Add new backend providers:
/// enum BackendProvider { direct, firebase, supabase, custom }
///
/// // Add environment-specific config:
/// class AppConfig {
///   static bool get isDevelopment => kDebugMode;
///   static String get apiVersion => isDevelopment ? 'v1' : 'v2';
/// }
///
/// // Add feature flags:
/// class AppConfig {
///   static const bool enableExperimentalFeatures = bool.fromEnvironment('EXPERIMENTAL');
/// }
/// ```
class AppConfig {
  // SECURITY WARNING:
  // For local testing only, you can set your API key below.
  // ⚠️  NEVER commit or deploy with this key set - it becomes publicly visible in web builds!
  // ⚠️  For production deployment, use backend proxy to keep API keys secure.
  static const String testingOnlyOpenRouterApiKey =
      ''; // Paste your key here for local testing only

  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: testingOnlyOpenRouterApiKey,
  );

  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';

  static const String appName = 'AI Chat Template';
  static const String appUrl =
      'https://your-app-url.com'; // Optional for rankings

  // Backend provider mode. 'direct' calls OpenRouter from the client (dev only).
  // For production, switch to 'firebase' or 'supabase' and configure the proxy URLs below.
  static const BackendProvider backendProvider = BackendProvider.direct;

  // Helper to check if API key is configured
  static bool get isApiKeyConfigured => openRouterApiKey.isNotEmpty;

  // Backend proxy endpoints (configure when using firebase/supabase)
  // Firebase HTTPS Function or Cloud Run URL that proxies OpenRouter
  static const String firebaseProxyUrl = '';
  // Supabase Edge Function URL that proxies OpenRouter
  static const String supabaseEdgeFunctionUrl = '';

  // Available models on OpenRouter
  static const List<String> availableModels = [];

  static const Map<String, String> modelDisplayNames = {};
}
