import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.green,
            titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Add Task'),
                  content: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          Provider.of<TaskProvider>(context, listen: false)
                              .addTask(_controller.text);
                          _controller.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return taskProvider.tasks.isEmpty
              ? Center(child: Text('No tasks yet! Add some.'))
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return AnimatedListTile(
                      key: ValueKey(task.name + index.toString()),
                      task: task,
                      index: index,
                      onToggle: () => taskProvider.toggleTask(index),
                      onDelete: () => taskProvider.deleteTask(index),
                    );
                  },
                );
        },
      ),
    );
  }
}

class AnimatedListTile extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AnimatedListTile({
    required Key key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AnimatedListTileState createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          leading: Checkbox(
            value: widget.task.isComplete,
            onChanged: (value) => widget.onToggle(),
          ),
          title: Text(
            widget.task.name,
            style: TextStyle(
              fontSize: 16,
              decoration: widget.task.isComplete ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
        ),
      ),
    );
  }
}