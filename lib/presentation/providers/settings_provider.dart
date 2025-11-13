import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models.dart';
import '../../data/services/provider_service.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/mcp_service.dart';
import '../../core/config.dart';

class SettingsProvider extends ChangeNotifier {
  final ProviderService _providerService = ProviderService();
  final TTSService _ttsService = TTSService();
  final MCPService _mcpService = MCPService();

  List<AIProvider> _customProviders = [];
  Set<String> _enabledProviderIds = {};
  TTSSettings _ttsSettings = const TTSSettings(provider: 'system', modelId: '');
  List<MCPServer> _mcpServers = [];
  bool _isLoading = false;

  List<AIProvider> get customProviders => _customProviders;
  List<AIProvider> get allProviders => [...builtInProviders, ..._customProviders];
  List<AIProvider> get enabledProviders => allProviders.where((p) => p.isEnabled).toList();
  TTSSettings get ttsSettings => _ttsSettings;
  List<MCPServer> get mcpServers => _mcpServers;
  bool get isLoading => _isLoading;

  List<AIProvider> get builtInProviders {
    return AppConfig.builtInProviders.map((builtIn) {
      return AIProvider(
        id: builtIn.id,
        name: builtIn.name,
        baseUrl: builtIn.baseUrl,
        apiKey: '', // Built-in providers need API keys from user
        isEnabled: _enabledProviderIds.contains(builtIn.id),
        isBuiltIn: true,
        models: builtIn.models,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadEnabledProviders(),
        _loadProviders(),
        _loadTTSSettings(),
        _loadMCPServers(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadEnabledProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledIds = prefs.getStringList('enabled_provider_ids');
    if (enabledIds != null) {
      _enabledProviderIds = enabledIds.toSet();
    } else {
      // Default: enable OpenRouter
      _enabledProviderIds = {'openrouter'};
      await _saveEnabledProviders();
    }
  }

  Future<void> _saveEnabledProviders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('enabled_provider_ids', _enabledProviderIds.toList());
  }

  Future<void> _loadProviders() async {
    final savedProviders = await _providerService.getProviders();
    _customProviders = savedProviders.map((p) {
      return p.copyWith(isEnabled: _enabledProviderIds.contains(p.id));
    }).toList();
  }

  Future<void> _loadTTSSettings() async {
    _ttsSettings = await _ttsService.getSettings();
  }

  Future<void> _loadMCPServers() async {
    _mcpServers = await _mcpService.getServers();
  }

  Future<void> toggleProvider(String providerId, bool enabled) async {
    if (enabled) {
      _enabledProviderIds.add(providerId);
    } else {
      _enabledProviderIds.remove(providerId);
    }
    await _saveEnabledProviders();
    await _loadProviders(); // Reload to update isEnabled state
    notifyListeners();
  }

  Future<void> addProvider(AIProvider provider) async {
    await _providerService.addProvider(provider);
    // Auto-enable newly added provider
    _enabledProviderIds.add(provider.id);
    await _saveEnabledProviders();
    await _loadProviders();
    notifyListeners();
  }

  Future<void> updateProvider(AIProvider provider) async {
    await _providerService.updateProvider(provider);
    await _loadProviders();
    notifyListeners();
  }

  Future<void> deleteProvider(String id) async {
    await _providerService.deleteProvider(id);
    _enabledProviderIds.remove(id);
    await _saveEnabledProviders();
    await _loadProviders();
    notifyListeners();
  }

  Future<List<String>> fetchModels(String baseUrl, String apiKey) async {
    return await _providerService.fetchModelsFromProvider(baseUrl, apiKey);
  }

  Future<void> updateTTSSettings(TTSSettings settings) async {
    await _ttsService.saveSettings(settings);
    _ttsSettings = settings;
    notifyListeners();
  }

  Future<List<Map<String, String>>> getAvailableVoices() async {
    return await _ttsService.getAvailableVoices();
  }

  Future<List<String>> getAvailableLanguages() async {
    return await _ttsService.getAvailableLanguages();
  }

  Future<void> speakText(String text) async {
    await _ttsService.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  Future<void> addMCPServer(MCPServer server) async {
    await _mcpService.addServer(server);
    await _loadMCPServers();
    notifyListeners();
  }

  Future<void> updateMCPServer(MCPServer server) async {
    await _mcpService.updateServer(server);
    await _loadMCPServers();
    notifyListeners();
  }

  Future<void> deleteMCPServer(String id) async {
    await _mcpService.deleteServer(id);
    await _loadMCPServers();
    notifyListeners();
  }

  List<MCPServer> get enabledMCPServers => _mcpServers.where((s) => s.isEnabled).toList();
}
