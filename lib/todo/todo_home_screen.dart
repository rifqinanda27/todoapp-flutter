import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_dicoding_submission/todo/todo_add_list.dart';
import 'package:todolist_app_dicoding_submission/todo/todo_edit_list.dart';

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TodoHomeScreenState();
}

class TodoItem {
  String title;
  bool isDone;
  final Key key;

  TodoItem({required this.title, this.isDone = false}) : key = UniqueKey();

  // Konversi ke Map untuk disimpan
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  // Membuat objek dari Map
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isDone: json['isDone'],
    );
  }
}


// Stateless widget for the section header
class TodoSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onTap;

  const TodoSectionHeader({
    Key? key,
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Stateless widget for todo item
class TodoListItem extends StatelessWidget {
  final TodoItem todoItem;
  final Function(bool) onStatusChanged;
  final Function(String) onOptionSelected;

  const TodoListItem({
    Key? key,
    required this.todoItem,
    required this.onStatusChanged,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: todoItem.key,
      color: Colors.white,
      child: ListTile(
        title: Text(
          todoItem.title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              activeColor: Colors.blue,
              value: todoItem.isDone,
              onChanged: onStatusChanged,
            ),
            PopupMenuButton<String>(
              onSelected: onOptionSelected,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'Edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  final List<TodoItem> _todoList = [];
  bool _isNotDoneExpanded = true;
  bool _isDoneExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadTodoList(); // Load data saat aplikasi dijalankan
  }

  // Fungsi untuk load data
  Future<void> _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todo_list');

    if (todosJson != null) {
      final List<dynamic> decodedList = jsonDecode(todosJson);
      setState(() {
        _todoList.clear();
        _todoList.addAll(decodedList.map((item) => TodoItem.fromJson(item)));
      });
    }
  }

  // Fungsi untuk simpan data
  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson =
    jsonEncode(_todoList.map((todo) => todo.toJson()).toList());
    await prefs.setString('todo_list', todosJson);
  }

  // Modifikasi fungsi ini untuk menyimpan setiap kali ada perubahan
  void _addTodoItem(String title) {
    setState(() {
      _todoList.add(TodoItem(title: title));
    });
    _saveTodoList();
  }

  void _updateTodoItem(TodoItem item, String newTitle) {
    setState(() {
      item.title = newTitle;
    });
    _saveTodoList();
  }

  void _deleteTodoItem(TodoItem item) {
    setState(() {
      _todoList.remove(item);
    });
    _saveTodoList();
  }

  void _toggleTodoStatus(TodoItem item, bool isDone) {
    setState(() {
      item.isDone = isDone;
    });
    _saveTodoList();
  }

  @override
  Widget build(BuildContext context) {
    final doneTodos = _todoList.where((todo) => todo.isDone).toList();
    final notDoneTodos = _todoList.where((todo) => !todo.isDone).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Todo List App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _todoList.isEmpty
            ? const Center(
          child: Text(
            'Todo list kosong. Tambahkan tugas!',
            style: TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              if (notDoneTodos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodoSectionHeader(
                        title: 'Belum Selesai',
                        count: notDoneTodos.length,
                        isExpanded: _isNotDoneExpanded,
                        onTap: () {
                          setState(() {
                            _isNotDoneExpanded = !_isNotDoneExpanded;
                          });
                        },
                      ),
                      AnimatedCrossFade(
                        firstChild: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notDoneTodos.length,
                          itemBuilder: (context, index) {
                            final todoItem = notDoneTodos[index];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child,
                                  Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: TodoListItem(
                                todoItem: todoItem,
                                onStatusChanged: (bool value) {
                                  _toggleTodoStatus(todoItem, value); // Panggil fungsi ini
                                },
                                onOptionSelected: (value) async {
                                  if (value == 'Delete') {
                                    _deleteTodoItem(todoItem); // Hapus dengan fungsi simpan
                                  } else if (value == 'Edit') {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTodoListScreen(
                                          initialTitle: todoItem.title,
                                          onSave: (newTitle) {
                                            _updateTodoItem(todoItem, newTitle); // Edit dengan simpan
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        secondChild: const SizedBox(),
                        crossFadeState: _isNotDoneExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              if (doneTodos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodoSectionHeader(
                        title: 'Selesai',
                        count: doneTodos.length,
                        isExpanded: _isDoneExpanded,
                        onTap: () {
                          setState(() {
                            _isDoneExpanded = !_isDoneExpanded;
                          });
                        },
                      ),
                      AnimatedCrossFade(
                        firstChild: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: doneTodos.length,
                          itemBuilder: (context, index) {
                            final todoItem = doneTodos[index];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child,
                                  Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: TodoListItem(
                                todoItem: todoItem,
                                onStatusChanged: (bool value) {
                                  _toggleTodoStatus(todoItem, value); // Panggil fungsi ini
                                },
                                onOptionSelected: (value) async {
                                  if (value == 'Delete') {
                                    _deleteTodoItem(todoItem); // Hapus dengan fungsi simpan
                                  } else if (value == 'Edit') {
                                    await Navigator.push(//comment
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTodoListScreen(
                                          initialTitle: todoItem.title,
                                          onSave: (newTitle) {
                                            _updateTodoItem(todoItem, newTitle); // Edit dengan simpan
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        secondChild: const SizedBox(),
                        crossFadeState: _isDoneExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newTodo = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTodoListScreen(),
              ),
            );
            if (newTodo != null && newTodo is String) {
              _addTodoItem(newTodo); // Gunakan fungsi ini
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}