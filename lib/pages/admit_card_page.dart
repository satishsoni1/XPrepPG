import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/brand.dart';
import '../models/student.dart';
import '../services/data_service.dart';
import 'exam_page.dart';

class AdmitCardPage extends StatelessWidget {
  final Student student;

  const AdmitCardPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Admit Card",style: TextStyle(color: Colors.white)), backgroundColor: Brand.primary),
      body: FutureBuilder(
        future: ds.loadExam(student.examId),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final exam = snap.data!;
          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 650),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(student.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(student.studentId),

                    const SizedBox(height: 20),
                    Text("Exam: ${exam.title}", style: const TextStyle(fontSize: 20)),
                    Text("Duration: ${exam.durationMinutes} minutes"),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Brand.primary,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: () async {
                        await ds.startAttempt(student, exam);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ExamPage()),
                        );
                      },
                      child: const Text("Start Exam",style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
