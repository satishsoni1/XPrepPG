// lib/models/exam.dart
import 'question.dart';

class Exam {
  final String id;
  final String title;
  final int durationMinutes;
  final List<Question> questions;

  Exam({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.questions,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      questions: (json['questions'] as List)
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'durationMinutes': durationMinutes,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
