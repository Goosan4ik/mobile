import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoItemAdapter());
  await Hive.openBox<ToDoItem>('todos');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Задачи',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final todoBox = Hive.box<ToDoItem>('todos');
  final List<ToDoItem> _shownTodos = [];

  int _currentFilter = 0;

  @override
  void initState() {
    super.initState();
    _updateShownTodos();
  }

  void _updateShownTodos() {
    var all = todoBox.values.toList();

    _shownTodos.clear();

    if (_currentFilter == 1) {
      for (var item in all) {
        if (!item.isActive) {
          _shownTodos.add(item);
        }
      }
    } else if (_currentFilter == 2) {
      for (var item in all) {
        if (item.isActive) {
          _shownTodos.add(item);
        }
      }
    } else {
      _shownTodos.addAll(all);
    }

    setState(() {});
  }

  void _openAddDialog() {
    var textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Новая задача'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Что нужно сделать?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                var text = textController.text.trim();
                if (text.isNotEmpty) {
                  var nextId = _getNextId();
                  var newTodo = ToDoItem(
                    id: nextId,
                    name: text,
                    isActive: false,
                  );
                  todoBox.add(newTodo);
                  _updateShownTodos();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _openEditDialog(ToDoItem todo) {
    var textController = TextEditingController(text: todo.name);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Изменить'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Название задачи',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                var newText = textController.text.trim();
                if (newText.isNotEmpty) {
                  todo.rename(newText);
                  _updateShownTodos();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodo(ToDoItem todo) {
    todo.toggle();
    _updateShownTodos();
  }

  void _askDeleteTodo(ToDoItem todo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Удалить?'),
          content: Text('Удалить "${todo.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () {
                todo.delete();
                _updateShownTodos();
                Navigator.pop(ctx);
              },
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
  }

  int _getNextId() {
    if (todoBox.isEmpty) return 1;
    var lastItem = todoBox.values.last;
    return lastItem.id + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Задачи',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterButton('Все', 0),
                FilterButton('Активные', 1),
                FilterButton('Выполненные', 2),
              ],
            ),
          ),

          Expanded(
            child: _shownTodos.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Список пуст',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавьте первую задачу',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _shownTodos.length,
              itemBuilder: (context, index) {
                var todo = _shownTodos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isActive,
                      onChanged: (_) => _toggleTodo(todo),
                    ),
                    title: Text(
                      todo.name,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: todo.isActive
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isActive ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _openEditDialog(todo),
                          color: Colors.black,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _askDeleteTodo(todo),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    onTap: () => _openEditDialog(todo),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget FilterButton(String text, int value) {
    var selected = _currentFilter == value;

    return OutlinedButton(
      onPressed: () {
        setState(() => _currentFilter = value);
        _updateShownTodos();
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Colors.black : null,
        foregroundColor: selected ? Colors.orange : Colors.white,
      ),
      child: Text(text),
    );
  }
}