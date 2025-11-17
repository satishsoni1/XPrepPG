// lib/pages/exam_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import 'result_page.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int qIndex = 0;
  Timer? timer;
  int remaining = 0;

  @override
  void initState() {
    super.initState();
    final ds = Provider.of<DataService>(context, listen: false);
    remaining = ds.currentExam.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => remaining--);
      if (remaining <= 0) _submit();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _submit() async {
    final ds = Provider.of<DataService>(context, listen: false);
    await ds.submitAttempt();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ResultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final exam = ds.currentExam;
    final q = exam.questions[qIndex];
    final selected = ds.attempt.answers[qIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${exam.title}",style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE4380C),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q${qIndex + 1}. ${q.text}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ...List.generate(q.options.length, (i) {
                    return ListTile(
                      leading: Radio(
                        value: i,
                        groupValue: selected,
                        onChanged: (v) {
                          ds.saveAnswer(qIndex, i);
                        },
                      ),
                      title: Text(q.options[i]),
                    );
                  }),
                  const Spacer(),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: qIndex > 0
                            ? () => setState(() => qIndex--)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                        ),
                        child: const Text("Previous",style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: qIndex < exam.questions.length - 1
                            ? () => setState(() => qIndex++)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                        ),
                        child: const Text("Next",style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Submit",style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  const Text("Questions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(exam.questions.length, (i) {
                      final ans = ds.attempt.answers[i];
                      return GestureDetector(
                        onTap: () => setState(() => qIndex = i),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ans != null ? Colors.green : Colors.white,
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text("${i + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
