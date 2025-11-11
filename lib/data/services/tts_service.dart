import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class TTSService {
  static const String _settingsKey = 'tts_settings';
  final FlutterTts _flutterTts = FlutterTts();
  TTSSettings? _currentSettings;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _currentSettings = await getSettings();
    await _applySettings(_currentSettings!);
    _isInitialized = true;
  }

  Future<TTSSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      return const TTSSettings(
        provider: 'system',
        modelId: '',
      );
    }
    
    try {
      return TTSSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return const TTSSettings(
        provider: 'system',
        modelId: '',
      );
    }
  }

  Future<void> saveSettings(TTSSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    _currentSettings = settings;
    await _applySettings(settings);
  }

  Future<void> _applySettings(TTSSettings settings) async {
    await _flutterTts.setVolume(settings.volume);
    await _flutterTts.setPitch(settings.pitch);
    await _flutterTts.setSpeechRate(settings.rate);
    await _flutterTts.setLanguage(settings.language);
    
    if (settings.modelId.isNotEmpty) {
      await _flutterTts.setVoice({
        'name': settings.modelId,
        'locale': settings.language,
      });
    }
  }

  Future<List<Map<String, String>>> getAvailableVoices() async {
    final voices = await _flutterTts.getVoices;
    if (voices is List) {
      return voices.map<Map<String, String>>((voice) {
        if (voice is Map) {
          return {
            'name': voice['name']?.toString() ?? '',
            'locale': voice['locale']?.toString() ?? '',
          };
        }
        return {'name': '', 'locale': ''};
      }).where((v) => v['name']!.isNotEmpty).toList();
    }
    return [];
  }

  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    if (languages is List) {
      return languages.map((l) => l.toString()).toList();
    }
    return [];
  }

  Future<void> speak(String text) async {
    await initialize();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<bool> get isSpeaking async {
    final result = await _flutterTts.awaitSpeakCompletion(false);
    return result;
  }

  void dispose() {
    _flutterTts.stop();
  }
}
