// lib/services/sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncService {
  final String serverUrl;
  SyncService({required this.serverUrl});

  // Post a list of attempts to server
  Future<Map<String, dynamic>> syncAttempts(List<Map<String, dynamic>> attempts) async {
    final url = Uri.parse('$serverUrl/api/sync/attempts');
    final res = await http.post(url, body: jsonEncode({'attempts': attempts}), headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) throw Exception('Sync failed (${res.statusCode})');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
