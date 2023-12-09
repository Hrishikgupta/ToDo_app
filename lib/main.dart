import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> todos = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      todos = prefs.getStringList('todos') ?? [];
    });
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', todos);
  }

  Future<void> _showEditDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: TextField(
            controller: TextEditingController(text: todos[index]),
            onChanged: (modifiedTodo) {
              // Update the todo in the list
              setState(() {
                todos[index] = modifiedTodo;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                saveTodos();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(todos[index]),
                  onDismissed: (direction) {
                    setState(() {
                      
                      todos.removeAt(index);
                    });
                    saveTodos();
                  },
                  child: ListTile(
                    title: Text(todos[index]),
                    onTap: () {
                      _showEditDialog(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    onSubmitted: (newTodo) {
                      if (newTodo.isNotEmpty) {
                        setState(() {
                          todos.add(newTodo);
                          textController.clear();
                        });
                        saveTodos();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter a new todo',
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      setState(() {
                        todos.add(textController.text);
                        textController.clear();
                      });
                      saveTodos();
                    }
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showClearAllDialog();
            },
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
  Future<void> _showClearAllDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Todos'),
          content: Text('Are you sure you want to clear all todos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todos.clear();
                });
                saveTodos();
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
