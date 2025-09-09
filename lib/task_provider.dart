import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String name;
  bool isComplete;

  Task(this.name, this.isComplete);
}

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskNames = prefs.getStringList('taskNames') ?? [];
    final taskCompletes = prefs.getStringList('taskCompletes') ?? [];
    _tasks = List.generate(
      taskNames.length,
      (i) => Task(taskNames[i], taskCompletes[i] == 'true'),
    );
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    _tasks.add(Task(name, false));
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(int index) async {
    _tasks[index].isComplete = !_tasks[index].isComplete;
    await _saveTasks();
    notifyListeners();
  }

  Future<void> deleteTask(int index) async {
    _tasks.removeAt(index);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('taskNames', _tasks.map((t) => t.name).toList());
    prefs.setStringList('taskCompletes', _tasks.map((t) => t.isComplete.toString()).toList());
  }
}