import 'package:hive/hive.dart';
part 'test.g.dart';

@HiveType(typeId: 99)
class TestHive {
  @HiveField(0)
  String name;

  TestHive(this.name);
}
