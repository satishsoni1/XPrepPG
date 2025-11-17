// lib/models/student.dart
class Student {
  final String studentId;
  final String name;
  final String email;
  final String centreId;
  final String examId;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.centreId,
    required this.examId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      name: json['name'],
      email: json['email'] ?? '',
      centreId: json['centreId'],
      examId: json['examId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'name': name,
        'email': email,
        'centreId': centreId,
        'examId': examId,
      };
}
