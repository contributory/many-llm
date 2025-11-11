import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/settings_provider.dart';
import '../../widgets/settings/providers_tab.dart';
import '../../widgets/settings/tts_tab.dart';
import '../../widgets/settings/mcp_tab.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.server, size: 20), text: 'Providers'),
            Tab(icon: Icon(LucideIcons.volume2, size: 20), text: 'TTS'),
            Tab(icon: Icon(LucideIcons.plug, size: 20), text: 'MCP Servers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProvidersTab(),
          TTSTab(),
          MCPTab(),
        ],
      ),
    );
  }
}
