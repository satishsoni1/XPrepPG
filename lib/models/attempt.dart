// lib/models/attempt.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'attempt.g.dart';

@HiveType(typeId: 1)
class AttemptModel extends HiveObject {
  @HiveField(0)
  String examId;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  List<int?> answers;

  @HiveField(3)
  List<bool> reviewFlags;

  @HiveField(4)
  bool finished;

  @HiveField(5)
  String? finishedAt;

  @HiveField(6)
  int? score;

  @HiveField(7)
  List<dynamic>? details; // stored as maps

  @HiveField(8)
  bool synced;

  @HiveField(9)
  String? syncedAt;

  AttemptModel({
    required this.examId,
    required this.studentId,
    required this.answers,
    required this.reviewFlags,
    this.finished = false,
    this.finishedAt,
    this.score,
    this.details,
    this.synced = false,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'studentId': studentId,
      'answers': answers,
      'reviewFlags': reviewFlags,
      'finished': finished,
      'finishedAt': finishedAt,
      'score': score,
      'details': details,
      'synced': synced,
      'syncedAt': syncedAt,
    };
  }

  factory AttemptModel.fromMap(Map<String, dynamic> map) {
    return AttemptModel(
      examId: map['examId'],
      studentId: map['studentId'],
      answers: List<int?>.from(map['answers']),
      reviewFlags: List<bool>.from(map['reviewFlags']),
      finished: map['finished'] ?? false,
      finishedAt: map['finishedAt'],
      score: map['score'],
      details: map['details'],
      synced: map['synced'] ?? false,
      syncedAt: map['syncedAt'],
    );
  }
}
