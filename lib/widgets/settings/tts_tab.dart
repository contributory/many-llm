import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models.dart';
import '../../presentation/providers/settings_provider.dart';

class TTSTab extends StatefulWidget {
  const TTSTab({super.key});

  @override
  State<TTSTab> createState() => _TTSTabState();
}

class _TTSTabState extends State<TTSTab> {
  List<Map<String, String>> _availableVoices = [];
  List<String> _availableLanguages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoicesAndLanguages();
  }

  List<DropdownMenuItem<String>> _getProviderModels(SettingsProvider provider, String providerId) {
    final selectedProvider = provider.providers.where((p) => p.id == providerId).firstOrNull;
    if (selectedProvider == null) return [];
    return selectedProvider.models.map((model) => DropdownMenuItem(
      value: model,
      child: Text(model),
    )).toList();
  }

  Future<void> _loadVoicesAndLanguages() async {
    final settingsProvider = context.read<SettingsProvider>();
    final voices = await settingsProvider.getAvailableVoices();
    final languages = await settingsProvider.getAvailableLanguages();
    
    setState(() {
      _availableVoices = voices;
      _availableLanguages = languages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.ttsSettings;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text-to-Speech Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Configure voice and speech parameters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: settings.provider.isEmpty ? 'system' : settings.provider,
                        decoration: const InputDecoration(
                          labelText: 'TTS Provider',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(LucideIcons.server),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'system',
                            child: Text('System TTS'),
                          ),
                          ...settingsProvider.providers
                            .where((p) => p.models.isNotEmpty)
                            .map((provider) => DropdownMenuItem(
                              value: provider.id,
                              child: Text(provider.name),
                            )),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.updateTTSSettings(
                              settings.copyWith(provider: value, modelId: ''),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: settings.language.isEmpty || !_availableLanguages.contains(settings.language)
                          ? (_availableLanguages.isNotEmpty ? _availableLanguages.first : null)
                          : settings.language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(LucideIcons.globe),
                        ),
                        items: _availableLanguages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.updateTTSSettings(
                              settings.copyWith(language: value),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (settings.provider == 'system') ...[
                        DropdownButtonFormField<String>(
                          value: settings.modelId.isEmpty ? null : settings.modelId,
                          decoration: InputDecoration(
                            labelText: 'Voice',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(LucideIcons.mic, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                          items: _availableVoices.map((voice) {
                            final name = voice['name']!;
                            final locale = voice['locale']!;
                            return DropdownMenuItem(
                              value: name,
                              child: Text('$name ($locale)'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              settingsProvider.updateTTSSettings(
                                settings.copyWith(modelId: value),
                              );
                            }
                          },
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          value: settings.modelId.isEmpty ? null : settings.modelId,
                          decoration: const InputDecoration(
                            labelText: 'TTS Model',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(LucideIcons.mic),
                          ),
                          items: _getProviderModels(settingsProvider, settings.provider),
                          onChanged: (value) {
                            if (value != null) {
                              settingsProvider.updateTTSSettings(
                                settings.copyWith(modelId: value),
                              );
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Volume: ${(settings.volume * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: settings.volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(settings.volume * 100).toInt()}%',
                        onChanged: (value) {
                          settingsProvider.updateTTSSettings(
                            settings.copyWith(volume: value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pitch: ${settings.pitch.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: settings.pitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        label: settings.pitch.toStringAsFixed(1),
                        onChanged: (value) {
                          settingsProvider.updateTTSSettings(
                            settings.copyWith(pitch: value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Speed: ${settings.rate.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: settings.rate,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: settings.rate.toStringAsFixed(1),
                        onChanged: (value) {
                          settingsProvider.updateTTSSettings(
                            settings.copyWith(rate: value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: settings.autoPlay,
                        onChanged: (value) {
                          settingsProvider.updateTTSSettings(
                            settings.copyWith(autoPlay: value),
                          );
                        },
                        title: const Text('Auto-play responses'),
                        subtitle: const Text('Automatically speak AI responses'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          settingsProvider.speakText(
                            'Hello! This is a test of the text to speech system.',
                          );
                        },
                        icon: const Icon(LucideIcons.play, size: 18),
                        label: const Text('Test Voice'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
