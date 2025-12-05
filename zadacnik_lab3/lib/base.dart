import 'package:hive_flutter/hive_flutter.dart';

class ToDoList {
  final todos = <Map>[];
  final storage = Hive.box('todo_storage');

  void load() {
    final saved = storage.get('todos', defaultValue: []);
    if (saved is List) {
      todos.clear();
      todos.addAll(saved.cast<Map>());
    }
  }

  void save() {
    storage.put('todos', todos);
  }

  void add(String title) {
    final newItem = {
      'title': title,
      'done': false,
      'created': DateTime.now(),
    };
    todos.add(newItem);
    save();
  }

  void removeAt(int index) {
    if (index >= 0 && index < todos.length) {
      todos.removeAt(index);
      save();
    }
  }

  void toggleDone(int index) {
    if (index >= 0 && index < todos.length) {
      final item = todos[index];
      item['done'] = !(item['done'] as bool);
      save();
    }
  }

  void editTitle(int index, String newTitle) {
    if (index >= 0 && index < todos.length) {
      todos[index]['title'] = newTitle;
      save();
    }
  }
}