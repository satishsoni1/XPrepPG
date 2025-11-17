// lib/services/sync_manager.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'remote_sync_service.dart';
import 'internet_service.dart';

enum SyncStatus { idle, syncing, success, failed, waiting }

class SyncManager with ChangeNotifier {
  SyncManager._();
  static final SyncManager instance = SyncManager._();
  SyncStatus _current = SyncStatus.idle;
  SyncStatus get status => _current; // <-- ADD THIS
  late RemoteSyncService remote;
  late InternetService internet;
  bool _initialized = false;

  final StreamController<SyncStatus> _statusCtrl = StreamController.broadcast();
  Stream<SyncStatus> get statusStream => _statusCtrl.stream;

  Box get _attemptBox => Hive.box('attempts_box');

  void configure({
    required RemoteSyncService remoteService,
    required InternetService internetService,
  }) {
    if (_initialized) return;
    _initialized = true;

    remote = remoteService;
    internet = internetService;

    // auto attempt when online
    internet.onStateChanged.listen((state) {
      if (state == ConnectivityState.online) {
        _processQueue();
      }
    });
  }

  void start() {
    internet.start();

    Timer.periodic(const Duration(seconds: 60), (_) {
      _processQueue();
    });
  }

  void _setStatus(SyncStatus s) {
    _current = s;
    _statusCtrl.add(s);
    notifyListeners();
  }

  void enqueue(String key) {
    Future.microtask(() => _processQueue());
  }

  List<Map<String, dynamic>> _pending() {
    final out = <Map<String, dynamic>>[];
    for (var key in _attemptBox.keys) {
      final raw = _attemptBox.get(key);
      if (raw is Map && (raw['finished'] == true) && (raw['synced'] != true)) {
        final map = Map<String, dynamic>.from(raw);
        map['localKey'] = key;
        out.add(map);
      }
    }
    return out;
  }

  bool _syncing = false;

  Future<void> _processQueue() async {
    if (_syncing) return;
    if (internet.lastState != ConnectivityState.online) {
      _setStatus(SyncStatus.waiting);
      return;
    }

    final pending = _pending();
    if (pending.isEmpty) {
      _setStatus(SyncStatus.idle);
      return;
    }

    _syncing = true;
    _setStatus(SyncStatus.syncing);

    const maxRetries = 5;

    for (int i = 1; i <= maxRetries; i++) {
      try {
        final payload = pending.map((e) {
          final m = Map<String, dynamic>.from(e);
          m.remove('localKey');
          return m;
        }).toList();

        final res = await remote.syncAttempts(payload);
        if (res['success'] == true) {
          // mark as synced locally
          for (var p in pending) {
            final key = p['localKey'];
            final raw = _attemptBox.get(key);

            if (raw is Map) {
              final m = Map<String, dynamic>.from(raw);
              m['synced'] = true;
              m['syncedAt'] = DateTime.now().toString();
              _attemptBox.put(key, m);
            }
          }

          _syncing = false;
          _setStatus(SyncStatus.success);
          return;
        }
      } catch (_) {
        // exponential backoff
        final wait = min(30, pow(2, i).toInt());
        await Future.delayed(Duration(seconds: wait));
      }
    }

    _syncing = false;
    _setStatus(SyncStatus.failed);
  }

  Future<void> triggerProcessQueue() async {
    // safely call the internal processor
    await _processQueue();
  }
}
