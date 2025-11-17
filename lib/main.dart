// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/data_service.dart';
import 'services/qpack_service.dart';
import 'services/remote_sync_service.dart';
import 'services/sync_manager.dart';
import 'services/internet_service.dart';

import 'pages/student_login_page.dart';

// Models (Hive adapters)
import 'models/attempt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AttemptModelAdapter());
  await Hive.openBox('attempts_box');

  // Setup services
  final qpack = QPackService(serverUrl: "http://127.0.0.1:5000");
  final remoteSync = RemoteSyncService(serverUrl: "http://127.0.0.1:5000");
  final internetService = InternetService(remote: remoteSync);

  // SyncManager final setup
  SyncManager.instance.configure(
    remoteService: remoteSync,
    internetService: internetService,
  );
  SyncManager.instance.start();

  runApp(MyApp(
    qpackService: qpack,
    remoteSyncService: remoteSync,
  ));
}

class MyApp extends StatelessWidget {
  final QPackService qpackService;
  final RemoteSyncService remoteSyncService;

  const MyApp({
    super.key,
    required this.qpackService,
    required this.remoteSyncService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataService(
        qpackService: qpackService,
        remoteSyncService: remoteSyncService,
      ),
      child: MaterialApp(
        title: 'XPrepPG Exam Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFE4380C), // Brand primary
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE4380C),
            primary: const Color(0xFFE4380C),
          ),
          useMaterial3: true,
        ),
        home: const StudentLoginPage(),
      ),
    );
  }
}
