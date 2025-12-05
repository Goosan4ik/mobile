
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class ToDoItem extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isActive;

  ToDoItem({
    required this.id,
    required this.name,
    this.isActive = false,
  });

  void toggle() {
    isActive = !isActive;
    save();
  }

  void rename(String newName) {
    name = newName;
    save();
  }
}