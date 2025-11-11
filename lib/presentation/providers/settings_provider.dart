import 'package:flutter/foundation.dart';
import '../../data/models.dart';
import '../../data/services/provider_service.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/mcp_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ProviderService _providerService = ProviderService();
  final TTSService _ttsService = TTSService();
  final MCPService _mcpService = MCPService();

  List<AIProvider> _providers = [];
  TTSSettings _ttsSettings = const TTSSettings(provider: 'system', modelId: '');
  List<MCPServer> _mcpServers = [];
  bool _isLoading = false;

  List<AIProvider> get providers => _providers;
  TTSSettings get ttsSettings => _ttsSettings;
  List<MCPServer> get mcpServers => _mcpServers;
  bool get isLoading => _isLoading;

  AIProvider? get defaultProvider => _providers.where((p) => p.isDefault).firstOrNull;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadProviders(),
        _loadTTSSettings(),
        _loadMCPServers(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProviders() async {
    _providers = await _providerService.getProviders();
  }

  Future<void> _loadTTSSettings() async {
    _ttsSettings = await _ttsService.getSettings();
  }

  Future<void> _loadMCPServers() async {
    _mcpServers = await _mcpService.getServers();
  }

  Future<void> addProvider(AIProvider provider) async {
    await _providerService.addProvider(provider);
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
