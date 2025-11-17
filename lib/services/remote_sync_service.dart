// lib/services/remote_sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteSyncService {
  final String serverUrl;

  RemoteSyncService({required this.serverUrl});

  Future<Map<String, dynamic>> syncAttempts(List<Map<String, dynamic>> attempts,
      {int timeoutSeconds = 20}) async {
    final uri = Uri.parse("$serverUrl/api/sync");

    final res = await http
        .post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"attempts": attempts}),
        )
        .timeout(Duration(seconds: timeoutSeconds));

    return jsonDecode(res.body);
  }

  Future<bool> ping({int timeoutSeconds = 3}) async {
    try {
      final uri = Uri.parse(serverUrl);
      final res = await http
          .get(uri)
          .timeout(Duration(seconds: timeoutSeconds));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
