import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models.dart';

class ProviderService {
  static const String _providersKey = 'ai_providers';
  static const Duration _timeout = Duration(seconds: 30);

  Future<List<AIProvider>> getProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final providersJson = prefs.getString(_providersKey);
    
    if (providersJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(providersJson);
      return decoded.map((json) => AIProvider.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProviders(List<AIProvider> providers) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(providers.map((p) => p.toJson()).toList());
    await prefs.setString(_providersKey, encoded);
  }

  Future<AIProvider> addProvider(AIProvider provider) async {
    final providers = await getProviders();
    
    if (provider.isDefault) {
      final updatedProviders = providers.map((p) => p.copyWith(isDefault: false)).toList();
      updatedProviders.add(provider);
      await saveProviders(updatedProviders);
      return provider;
    }
    
    providers.add(provider);
    await saveProviders(providers);
    return provider;
  }

  Future<void> updateProvider(AIProvider provider) async {
    final providers = await getProviders();
    final index = providers.indexWhere((p) => p.id == provider.id);
    
    if (index == -1) return;
    
    if (provider.isDefault) {
      final updatedProviders = providers.map((p) => p.copyWith(isDefault: false)).toList();
      updatedProviders[index] = provider;
      await saveProviders(updatedProviders);
    } else {
      providers[index] = provider;
      await saveProviders(providers);
    }
  }

  Future<void> deleteProvider(String id) async {
    final providers = await getProviders();
    providers.removeWhere((p) => p.id == id);
    await saveProviders(providers);
  }

  Future<AIProvider?> getDefaultProvider() async {
    final providers = await getProviders();
    return providers.where((p) => p.isDefault).firstOrNull;
  }

  Future<List<String>> fetchModelsFromProvider(String baseUrl, String apiKey) async {
    try {
      final modelsUrl = baseUrl.endsWith('/') 
        ? '${baseUrl}models' 
        : '$baseUrl/models';
      
      final response = await http.get(
        Uri.parse(modelsUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['data'] is List) {
          return (data['data'] as List)
            .map((model) => model['id'] as String)
            .toList();
        } else if (data['models'] is List) {
          return (data['models'] as List)
            .map((model) => model['id'] as String? ?? model.toString())
            .toList();
        }
      }
      
      throw Exception('Failed to fetch models: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch models: $e');
    }
  }
}
