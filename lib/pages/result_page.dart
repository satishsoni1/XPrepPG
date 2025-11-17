// lib/pages/result_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../models/question.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final attempt = ds.attempt;
    final exam = ds.currentExam;
    final student = ds.currentStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result",style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE4380C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // LEFT SIDE — questions and answers
            Expanded(
              child: ListView.builder(
                itemCount: exam.questions.length,
                itemBuilder: (_, i) {
                  final q = exam.questions[i];
                  final sel = attempt.answers[i];
                  final correct = sel == q.correctIndex;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Q${i + 1}. ${q.text}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Your Answer: ${sel != null ? q.options[sel] : 'Not answered'}",
                              style: TextStyle(
                                  color: correct ? Colors.green : Colors.red)),
                          Text("Correct: ${q.options[q.correctIndex]}",
                              style: const TextStyle(color: Colors.green)),
                          const SizedBox(height: 6),
                          Text("Explanation: ${q.explanation}",
                              style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 20),

            // RIGHT SIDE — summary
            SizedBox(
              width: 250,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${attempt.score}%",
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(student.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(student.studentId),
                      const SizedBox(height: 20),
                      Text("Correct: ${attempt.details?.where((d) => d['correct']).length}"),
                      Text("Total: ${exam.questions.length}"),
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
