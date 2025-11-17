// lib/services/internet_service.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'remote_sync_service.dart';

enum ConnectivityState { online, offline, unknown }

class InternetService {
  final _connectivity = Connectivity();
  StreamSubscription<dynamic>? _sub;
  final RemoteSyncService remote;

  InternetService({required this.remote});

  final StreamController<ConnectivityState> _stateCtrl =
      StreamController.broadcast();
  Stream<ConnectivityState> get onStateChanged => _stateCtrl.stream;

  ConnectivityState _last = ConnectivityState.unknown;
  ConnectivityState get lastState => _last;

  void start() {
    _sub = _connectivity.onConnectivityChanged.listen((_) {
      _evaluate();
    });

    _evaluate();
  }

  Future<void> _evaluate() async {
    try {
      final c = await _connectivity.checkConnectivity();
      if (c == ConnectivityResult.none) {
        _update(ConnectivityState.offline);
        return;
      }

      final ok = await remote.ping(timeoutSeconds: 2);
      _update(ok ? ConnectivityState.online : ConnectivityState.offline);
    } catch (_) {
      _update(ConnectivityState.offline);
    }
  }

  void _update(ConnectivityState s) {
    if (s != _last) {
      _last = s;
      _stateCtrl.add(s);
    }
  }

  void dispose() {
    _sub?.cancel();
    _stateCtrl.close();
  }
}
