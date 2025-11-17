// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttemptModelAdapter extends TypeAdapter<AttemptModel> {
  @override
  final int typeId = 1;

  @override
  AttemptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttemptModel(
      examId: fields[0] as String,
      studentId: fields[1] as String,
      answers: (fields[2] as List).cast<int?>(),
      reviewFlags: (fields[3] as List).cast<bool>(),
      finished: fields[4] as bool,
      finishedAt: fields[5] as String?,
      score: fields[6] as int?,
      details: (fields[7] as List?)?.cast<dynamic>(),
      synced: fields[8] as bool,
      syncedAt: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttemptModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.examId)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.answers)
      ..writeByte(3)
      ..write(obj.reviewFlags)
      ..writeByte(4)
      ..write(obj.finished)
      ..writeByte(5)
      ..write(obj.finishedAt)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.details)
      ..writeByte(8)
      ..write(obj.synced)
      ..writeByte(9)
      ..write(obj.syncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttemptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
