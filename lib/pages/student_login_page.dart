import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/brand.dart';
import '../services/data_service.dart';
import '../services/sync_manager.dart';
import '../services/internet_service.dart';
import 'admit_card_page.dart';
import 'centre_login_page.dart';
import 'widgets/offline_banner.dart';
import 'widgets/sync_status_widget.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _id = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder(
              stream: SyncManager.instance.internet.onStateChanged,
              builder: (_, snap) {
                final state = snap.data ?? SyncManager.instance.internet.lastState;
                return OfflineBanner(state: state);
              },
            ),

            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Student Login",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Brand.primary)),

                      const SizedBox(height: 20),

                      TextField(
                        controller: _id,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: "Student ID",
                          hintText: "E.g. S001",
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Brand.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: loading ? null : () async {
                            setState(() => loading = true);
                            final ok = await ds.studentLogin(_id.text.trim());
                            setState(() => loading = false);
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid ID")));
                              return;
                            }
                            final s = ds.getStudent(_id.text.trim())!;
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => AdmitCardPage(student: s)));
                          },
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Login", style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const SyncStatusWidget(),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CentreLoginPage()));
                        },
                        child: const Text("Centre Login"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
