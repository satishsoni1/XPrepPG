// lib/services/data_service.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/student.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../models/attempt.dart';

import 'remote_sync_service.dart';
import 'sync_manager.dart';
import 'qpack_service.dart';

class DataService extends ChangeNotifier {
  final QPackService qpackService;
  final RemoteSyncService remoteSyncService;

  DataService({
    required this.qpackService,
    required this.remoteSyncService,
  }) {
    // preload exams from local or fetch later
  }

  // -----------------------
  // LOCAL SAMPLE STUDENTS
  // -----------------------
  final List<Student> _students = [
    Student(studentId: 'S001', name: 'Asha Patel', email: '', centreId: 'C1', examId: 'E001'),
    Student(studentId: 'S002', name: 'Rahul Kumar', email: '', centreId: 'C1', examId: 'E001'),
    Student(studentId: 'S003', name: 'Priya Singh', email: '', centreId: 'C2', examId: 'E001'),
  ];

  Student? getStudent(String id) {
    try {
      return _students.firstWhere(
        (s) => s.studentId.toLowerCase() == id.toLowerCase(),
      );
    } on StateError {
      return null;
    }
  }

  Future<bool> studentLogin(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return getStudent(id) != null;
  }

  // -----------------------
  // EXAM HANDLING
  // -----------------------

  final Map<String, Exam> _exams = {};

  Future<Exam?> loadExam(String examId) async {
    if (_exams.containsKey(examId)) return _exams[examId];

    // Local sample exam
    final exam = Exam(
      id: 'E001',
      title: 'Sample Exam',
      durationMinutes: 10,
      questions: [
        Question(
          id: 'Q1',
          text: 'What is 2+2?',
          options: ['1', '2', '3', '4'],
          correctIndex: 3,
          explanation: '2+2 = 4.',
        ),
        Question(
          id: 'Q2',
          text: 'Capital of India?',
          options: ['Mumbai', 'New Delhi', 'Kolkata', 'Chennai'],
          correctIndex: 1,
          explanation: 'New Delhi is the capital.',
        ),
      ],
    );

    _exams[examId] = exam;
    return exam;
  }

  // -----------------------
  // ATTEMPTS
  // -----------------------

  late Exam currentExam;
  late Student currentStudent;
  late AttemptModel attempt;

  Future<void> startAttempt(Student s, Exam e) async {
    currentStudent = s;
    currentExam = e;

    attempt = AttemptModel(
      examId: e.id,
      studentId: s.studentId,
      answers: List<int?>.filled(e.questions.length, null),
      reviewFlags: List<bool>.filled(e.questions.length, false),
      finished: false,
    );
  }

  void saveAnswer(int qIndex, int optionIndex) {
    attempt.answers[qIndex] = optionIndex;
    notifyListeners();
  }

  Future<void> submitAttempt() async {
    final e = currentExam;
    int correctCount = 0;

    final details = <Map<String, dynamic>>[];

    for (int i = 0; i < e.questions.length; i++) {
      final q = e.questions[i];
      final sel = attempt.answers[i];
      final correct = sel != null && sel == q.correctIndex;

      if (correct) correctCount++;

      details.add({
        'questionId': q.id,
        'text': q.text,
        'options': q.options,
        'correctIndex': q.correctIndex,
        'selectedIndex': sel,
        'correct': correct,
        'explanation': q.explanation,
      });
    }

    attempt.finished = true;
    attempt.finishedAt = DateTime.now().toIso8601String();
    attempt.score = ((correctCount / e.questions.length) * 100).round();
    attempt.details = details;

    await _persistLocal(attempt);
  }

  Future<void> _persistLocal(AttemptModel a) async {
    final box = Hive.box('attempts_box');

    final key = "${a.examId}_${a.studentId}_${DateTime.now().millisecondsSinceEpoch}";
    box.put(key, a.toMap());

    SyncManager.instance.enqueue(key);
  }
  // Add this getter to expose registered students
List<Student> get students => List.unmodifiable(_students);

// Add this export helper (CSV) if not present
String exportStudentsCsv() {
  final rows = <List<String>>[
    ['studentId', 'name', 'email', 'centreId', 'examId'],
    ..._students.map((s) => [s.studentId, s.name, s.email, s.centreId, s.examId])
  ];
  return rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');
}

// Add method to retrieve attempts for a student (reads Hive attempts_box)
Future<List<Map<String, dynamic>>> getAttemptsForStudent(String studentId) async {
  final box = Hive.box('attempts_box');
  final out = <Map<String, dynamic>>[];
  for (final key in box.keys) {
    final val = box.get(key);
    if (val is Map) {
      if ((val['studentId'] ?? '') == studentId) {
        final m = Map<String, dynamic>.from(val);
        m['localKey'] = key;
        out.add(m);
      }
    }
  }
  // sort by finishedAt desc
  out.sort((a, b) {
    final da = DateTime.tryParse(a['finishedAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    final db = DateTime.tryParse(b['finishedAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    return db.compareTo(da);
  });
  return out;
}

}
