import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class MCPService {
  static const String _serversKey = 'mcp_servers';

  Future<List<MCPServer>> getServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = prefs.getString(_serversKey);
    
    if (serversJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(serversJson);
      return decoded.map((json) => MCPServer.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveServers(List<MCPServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(servers.map((s) => s.toJson()).toList());
    await prefs.setString(_serversKey, encoded);
  }

  Future<MCPServer> addServer(MCPServer server) async {
    final servers = await getServers();
    servers.add(server);
    await saveServers(servers);
    return server;
  }

  Future<void> updateServer(MCPServer server) async {
    final servers = await getServers();
    final index = servers.indexWhere((s) => s.id == server.id);
    
    if (index == -1) return;
    
    servers[index] = server;
    await saveServers(servers);
  }

  Future<void> deleteServer(String id) async {
    final servers = await getServers();
    servers.removeWhere((s) => s.id == id);
    await saveServers(servers);
  }

  Future<List<MCPServer>> getEnabledServers() async {
    final servers = await getServers();
    return servers.where((s) => s.isEnabled).toList();
  }
}
