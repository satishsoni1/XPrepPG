// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestHiveAdapter extends TypeAdapter<TestHive> {
  @override
  final int typeId = 99;

  @override
  TestHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestHive(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestHive obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
