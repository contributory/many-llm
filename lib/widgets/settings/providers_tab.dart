import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../data/models.dart';
import '../../presentation/providers/settings_provider.dart';

class ProvidersTab extends StatelessWidget {
  const ProvidersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final builtInProviders = settingsProvider.builtInProviders;
        final customProviders = settingsProvider.customProviders;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage AI providers and their models',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddProviderDialog(context),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Add Custom'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (builtInProviders.isNotEmpty) ...[
                    Text(
                      'Built-in Providers',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...builtInProviders.map((provider) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProviderCard(
                        provider: provider,
                        onToggle: (enabled) => settingsProvider.toggleProvider(provider.id, enabled),
                        onEdit: () => _showEditBuiltInProviderDialog(context, provider),
                        isBuiltIn: true,
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Custom Providers',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (customProviders.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.server,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No custom providers',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...customProviders.map((provider) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProviderCard(
                        provider: provider,
                        onToggle: (enabled) => settingsProvider.toggleProvider(provider.id, enabled),
                        onEdit: () => _showEditProviderDialog(context, provider),
                        onDelete: () => _deleteProvider(context, provider.id),
                        isBuiltIn: false,
                      ),
                    )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddProviderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProviderDialog(),
    );
  }

  void _showEditProviderDialog(BuildContext context, AIProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ProviderDialog(provider: provider),
    );
  }

  void _showEditBuiltInProviderDialog(BuildContext context, AIProvider provider) {
    showDialog(
      context: context,
      builder: (context) => BuiltInProviderDialog(provider: provider),
    );
  }

  void _deleteProvider(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Provider'),
        content: const Text('Are you sure you want to delete this provider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().deleteProvider(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final AIProvider provider;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isBuiltIn;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.isBuiltIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        provider.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isBuiltIn) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BUILT-IN',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onToggle != null)
                  Switch(
                    value: provider.isEnabled,
                    onChanged: onToggle,
                  ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.pencil, size: 18),
                    tooltip: isBuiltIn ? 'Edit API Key' : 'Edit',
                  ),
                if (!isBuiltIn && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.baseUrl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (provider.apiKey.isNotEmpty)
                  _buildInfoChip(
                    context,
                    LucideIcons.key,
                    'API Key: ${_maskApiKey(provider.apiKey)}',
                  )
                else if (isBuiltIn)
                  _buildInfoChip(
                    context,
                    LucideIcons.alertCircle,
                    'No API key configured',
                  ),
                _buildInfoChip(
                  context,
                  LucideIcons.cpu,
                  '${provider.models.length} models',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '••••••••';
    return '${apiKey.substring(0, 4)}••••${apiKey.substring(apiKey.length - 4)}';
  }
}

class ProviderDialog extends StatefulWidget {
  final AIProvider? provider;

  const ProviderDialog({super.key, this.provider});

  @override
  State<ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends State<ProviderDialog> {
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  List<String> _models = [];
  bool _isFetchingModels = false;
  String? _errorMessage;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider?.name ?? '');
    _baseUrlController = TextEditingController(text: widget.provider?.baseUrl ?? '');
    _apiKeyController = TextEditingController(text: widget.provider?.apiKey ?? '');
    _models = widget.provider?.models ?? [];
    if (widget.provider != null) _currentStep = 2; // Skip to settings if editing
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _fetchModels() async {
    if (_baseUrlController.text.isEmpty || _apiKeyController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter base URL and API key');
      return;
    }

    setState(() {
      _isFetchingModels = true;
      _errorMessage = null;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final models = await settingsProvider.fetchModels(
        _baseUrlController.text,
        _apiKeyController.text,
      );
      
      setState(() {
        _models = models;
        _isFetchingModels = false;
        if (models.isNotEmpty) _currentStep = 2;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isFetchingModels = false;
      });
    }
  }

  void _save() {
    if (_nameController.text.isEmpty || _baseUrlController.text.isEmpty || _apiKeyController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }

    final provider = AIProvider(
      id: widget.provider?.id ?? const Uuid().v4(),
      name: _nameController.text,
      baseUrl: _baseUrlController.text,
      apiKey: _apiKeyController.text,
      isEnabled: widget.provider?.isEnabled ?? true,
      models: _models,
      createdAt: widget.provider?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final settingsProvider = context.read<SettingsProvider>();
    if (widget.provider == null) {
      settingsProvider.addProvider(provider);
    } else {
      settingsProvider.updateProvider(provider);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 550,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.server,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider == null ? 'Add Provider' : 'Edit Provider',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure OpenAI-compatible API provider',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.provider == null) _buildStepIndicator(),
                    const SizedBox(height: 24),
                    if (_currentStep == 0) _buildBasicInfoStep(),
                    if (_currentStep == 1) _buildConnectionStep(),
                    if (_currentStep == 2) _buildSettingsStep(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0 && widget.provider == null)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _currentStep--),
                      icon: const Icon(LucideIcons.chevronLeft, size: 18),
                      label: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _currentStep == 2 ? _save : () {
                          if (_currentStep == 0 && _nameController.text.isEmpty) {
                            setState(() => _errorMessage = 'Please enter provider name');
                            return;
                          }
                          setState(() {
                            _currentStep++;
                            _errorMessage = null;
                          });
                        },
                        child: Text(_currentStep == 2 ? 'Save' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, 'Basic'),
        _buildStepLine(0),
        _buildStepDot(1, 'Connect'),
        _buildStepLine(1),
        _buildStepDot(2, 'Settings'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          height: 2,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Give your provider a recognizable name',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Provider Name',
            hintText: 'e.g., OpenRouter, OpenAI, DeepSeek',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(LucideIcons.tag),
            helperText: 'This name will appear in provider selection',
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
      ],
    );
  }

  Widget _buildConnectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter API credentials and fetch available models',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _baseUrlController,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'https://api.openai.com/v1',
            border: OutlineInputBorder(),
            prefixIcon: Icon(LucideIcons.link),
            helperText: 'API endpoint for the provider',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _apiKeyController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'sk-...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(LucideIcons.key),
            helperText: 'Your API authentication key',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isFetchingModels ? null : _fetchModels,
            icon: _isFetchingModels
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.download, size: 18),
            label: Text(_isFetchingModels ? 'Fetching Models...' : 'Fetch Models'),
          ),
        ),
        if (_models.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Successfully fetched ${_models.length} models',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click Next to continue',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
      ],
    );
  }

  Widget _buildSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure preferences for this provider',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available Models',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_models.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _models.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.cpu,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _models[index],
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Text(
                  'No models available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuiltInProviderDialog extends StatefulWidget {
  final AIProvider provider;

  const BuiltInProviderDialog({super.key, required this.provider});

  @override
  State<BuiltInProviderDialog> createState() => _BuiltInProviderDialogState();
}

class _BuiltInProviderDialogState extends State<BuiltInProviderDialog> {
  late TextEditingController _apiKeyController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.provider.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _save() {
    if (_apiKeyController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter an API key');
      return;
    }

    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.updateBuiltInProviderApiKey(widget.provider.id, _apiKeyController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.key,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit ${widget.provider.name} API Key',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure your API key for ${widget.provider.name}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              size: 20,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        hintText: 'Enter your ${widget.provider.name} API key',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(LucideIcons.key, size: 20),
                      ),
                      obscureText: true,
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your API key will be stored securely on your device and used to authenticate requests to ${widget.provider.name}.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
