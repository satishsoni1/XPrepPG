import 'package:flutter/material.dart';
import '../../services/sync_manager.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SyncManager.instance.statusStream,
      builder: (context, snap) {
        final status = snap.data ?? SyncManager.instance.status;

        switch (status) {
          case SyncStatus.syncing:
            return const Text("Syncing…", style: TextStyle(color: Colors.orange));
          case SyncStatus.success:
            return const Text("Synced", style: TextStyle(color: Colors.green));
          case SyncStatus.failed:
            return const Text("Sync failed", style: TextStyle(color: Colors.red));
          case SyncStatus.waiting:
            return const Text("Waiting for internet…", style: TextStyle(color: Colors.grey));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
