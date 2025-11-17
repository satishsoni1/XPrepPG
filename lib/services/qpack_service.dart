// lib/services/qpack_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/exam.dart';
import 'package:crypto/crypto.dart'; // optional for checksum verify

class QPackService {
  final String serverUrl;

  QPackService({required this.serverUrl});

  Future<Exam?> fetchExamPack(String packId) async {
    try {
      final uri = Uri.parse("$serverUrl/api/qpack/$packId");
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final map = jsonDecode(res.body);
      final encrypted = map['encrypted'];

      // 🔥 For now exam is unencrypted (you can add AES decrypt later)
      final decoded = jsonDecode(encrypted);

      return Exam.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }
}
