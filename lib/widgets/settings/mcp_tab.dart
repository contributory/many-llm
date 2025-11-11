import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../data/models.dart';
import '../../presentation/providers/settings_provider.dart';

class MCPTab extends StatelessWidget {
  const MCPTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final servers = settingsProvider.mcpServers;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage Model Context Protocol (MCP) servers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddServerDialog(context),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Add Server'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: servers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.plug,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No MCP servers configured',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add an MCP server to extend functionality',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: servers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      return MCPServerCard(
                        server: server,
                        onEdit: () => _showEditServerDialog(context, server),
                        onDelete: () => _deleteServer(context, server.id),
                        onToggle: (enabled) => _toggleServer(context, server, enabled),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  void _showAddServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MCPServerDialog(),
    );
  }

  void _showEditServerDialog(BuildContext context, MCPServer server) {
    showDialog(
      context: context,
      builder: (context) => MCPServerDialog(server: server),
    );
  }

  void _deleteServer(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete MCP Server'),
        content: const Text('Are you sure you want to delete this server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().deleteMCPServer(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleServer(BuildContext context, MCPServer server, bool enabled) {
    context.read<SettingsProvider>().updateMCPServer(
      server.copyWith(isEnabled: enabled),
    );
  }
}

class MCPServerCard extends StatelessWidget {
  final MCPServer server;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const MCPServerCard({
    super.key,
    required this.server,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
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
                        server.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: server.isEnabled 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          server.isEnabled ? 'ENABLED' : 'DISABLED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: server.isEnabled
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: server.isEnabled,
                  onChanged: onToggle,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              server.url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (server.apiKey != null) ...[
              const SizedBox(height: 12),
              _buildInfoChip(
                context,
                LucideIcons.key,
                'API Key: ${_maskApiKey(server.apiKey!)}',
              ),
            ],
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

class MCPServerDialog extends StatefulWidget {
  final MCPServer? server;

  const MCPServerDialog({super.key, this.server});

  @override
  State<MCPServerDialog> createState() => _MCPServerDialogState();
}

class _MCPServerDialogState extends State<MCPServerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _apiKeyController;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.server?.name ?? '');
    _urlController = TextEditingController(text: widget.server?.url ?? '');
    _apiKeyController = TextEditingController(text: widget.server?.apiKey ?? '');
    _isEnabled = widget.server?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final server = MCPServer(
      id: widget.server?.id ?? const Uuid().v4(),
      name: _nameController.text,
      url: _urlController.text,
      apiKey: _apiKeyController.text.isEmpty ? null : _apiKeyController.text,
      isEnabled: _isEnabled,
      config: widget.server?.config ?? {},
      createdAt: widget.server?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final settingsProvider = context.read<SettingsProvider>();
    if (widget.server == null) {
      settingsProvider.addMCPServer(server);
    } else {
      settingsProvider.updateMCPServer(server);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.server == null ? 'Add MCP Server' : 'Edit MCP Server'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Server Name',
                hintText: 'e.g., My MCP Server',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'https://mcp-server.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
              title: const Text('Enable server'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
