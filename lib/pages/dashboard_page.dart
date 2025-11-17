// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpreppg/models/attempt.dart';

import '../theme/brand.dart';
import '../services/data_service.dart';
import '../services/sync_manager.dart';
import '../services/internet_service.dart';
import 'admit_card_page.dart';
import 'result_page.dart';
import 'widgets/offline_banner.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    // NOTE: DataService should expose a `students` getter (List<Student>).
    final students = ds.students;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre Dashboard',style: TextStyle(color: Colors.white)),
        backgroundColor: Brand.primary,
        actions: [
          IconButton(
            tooltip: 'Export students CSV',
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              final csv = ds.exportStudentsCsv();
              // show CSV in dialog (for local save implement file write separately)
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Students CSV'),
                  content: SingleChildScrollView(child: SelectableText(csv)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Sync attempts now',
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _syncing ? null : () => _triggerSync(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            StreamBuilder(
              stream: SyncManager.instance.internet.onStateChanged,
              builder: (context, snap) {
                final state = snap.data ?? SyncManager.instance.internet.lastState;
                return OfflineBanner(state: state);
              },
            ),

            // Sync status and summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 8),
                  Text('${students.length} registered students', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  StreamBuilder(
                    stream: SyncManager.instance.statusStream,
                    builder: (context, snap) {
                      final status = snap.data ?? SyncManager.instance.status;
                      switch (status) {
                        case SyncStatus.syncing:
                          return Row(children: const [Icon(Icons.sync, color: Colors.orange), SizedBox(width: 6), Text('Syncing...')]);
                        case SyncStatus.success:
                          return Row(children: const [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 6), Text('Synced')]);
                        case SyncStatus.failed:
                          return Row(children: const [Icon(Icons.error, color: Colors.red), SizedBox(width: 6), Text('Sync failed')]);
                        case SyncStatus.waiting:
                          return Row(children: const [Icon(Icons.hourglass_empty), SizedBox(width: 6), Text('Waiting for internet')]);
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Student list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final s = students[idx];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: CircleAvatar(child: Text(s.name.isNotEmpty ? s.name[0] : s.studentId.substring(0,1))),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${s.studentId} • ${s.centreId}'),
                      trailing: Wrap(spacing: 6, children: [
                        TextButton(
                          onPressed: () {
                            // Open admit card page
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdmitCardPage(student: s)));
                          },
                          child: const Text('Admit'),
                        ),

                        TextButton(
                          onPressed: () async {
                            // Print/Download admit - for now show the admit dialog
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdmitCardPage(student: s)));
                          },
                          child: const Text('Print'),
                        ),

                        TextButton(
                          onPressed: () async {
                            // Check if attempt exists for this student and show result(s)
                            final attempts = await ds.getAttemptsForStudent(s.studentId);
                            if (attempts.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No results available')));
                              return;
                            }

                            // Show results list (if multiple attempts pick latest) - show dialog with selection
                            final chosen = await showModalBottomSheet<Map<String, dynamic>?>(
                              context: context,
                              builder: (_) {
                                return ListView(
                                  padding: const EdgeInsets.all(12),
                                  children: attempts.map((a) {
                                    return ListTile(
                                      title: Text('Exam: ${a['examId']} • Score: ${a['score'] ?? '-'}%'),
                                      subtitle: Text('Finished: ${a['finishedAt'] ?? '-'}'),
                                      onTap: () => Navigator.pop(context, a),
                                    );
                                  }).toList(),
                                );
                              },
                            );

                            if (chosen != null) {
                              // Navigate to ResultPage using route that accepts examId & studentId
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ResultPageWrapper(attemptMap: chosen)),
);
                            }
                          },
                          child: const Text('Results'),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerSync(BuildContext context) async {
    setState(() => _syncing = true);
    try {
      // Prefer calling SyncManager public trigger method if available
      if (SyncManager.instance != null) {
        // If SyncManager exposes a trigger method, use it; otherwise start() will also attempt
        try {
          await SyncManager.instance.triggerProcessQueue();
        } catch (_) {
          // fallback: ensure SyncManager is started (it auto-processes)
          SyncManager.instance.start();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync requested')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync error: $e')));
    } finally {
      setState(() => _syncing = false);
    }
  }
}

/// Simple wrapper to navigate to your existing ResultPage which expects examId & studentId.
/// If your ResultPage takes parameters differently, adjust this wrapper to call it correctly.
/// Wrapper for navigating to the ResultPage
class ResultPageWrapper extends StatefulWidget {
  final Map<String, dynamic> attemptMap; // the map returned from getAttemptsForStudent

  const ResultPageWrapper({super.key, required this.attemptMap});

  @override
  State<ResultPageWrapper> createState() => _ResultPageWrapperState();
}

class _ResultPageWrapperState extends State<ResultPageWrapper> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final ds = Provider.of<DataService>(context, listen: false);
      final map = widget.attemptMap;

      // examId and studentId should be present in the attempt map
      final examId = map['examId'] as String?;
      final studentId = map['studentId'] as String?;

      if (examId == null || studentId == null) {
        throw Exception('Invalid attempt data');
      }

      // Load exam into DataService (will return cached exam if present)
      final exam = await ds.loadExam(examId);
      if (exam == null) throw Exception('Exam not found: $examId');

      // Find student from DataService's student list (or leave currentStudent as is)
      final student = ds.getStudent(studentId);
      if (student == null) throw Exception('Student not found: $studentId');

      // Create AttemptModel from map and store on DataService so ResultPage can access it
      final attemptModel = AttemptModel.fromMap(map);

      // Assign into DataService (these are the same fields ResultPage expects)
      ds.currentExam = exam;
      ds.currentStudent = student;
      ds.attempt = attemptModel;

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    // Now DataService has currentExam/currentStudent/attempt set — show ResultPage
    return const ResultPage();
  }
}

