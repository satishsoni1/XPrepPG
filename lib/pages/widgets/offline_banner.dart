import 'package:flutter/material.dart';
import '../../services/internet_service.dart';

class OfflineBanner extends StatelessWidget {
  final ConnectivityState state;

  const OfflineBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == ConnectivityState.online) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      color: Colors.red.shade600,
      child: const Text(
        "Offline – data will sync when internet returns",
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
