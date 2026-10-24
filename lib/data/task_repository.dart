import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}

/// Stores tasks in browser local storage through SharedPreferences.
class TaskRepository {
  TaskRepository._(this._preferences);

  final SharedPreferences _preferences;

  static const String _storageKey = 'it126_tasks';

  static Future<TaskRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return TaskRepository._(preferences);
  }

  List<Task> _readTasks() {
    final jsonString = _preferences.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((item) {
      return Task.fromMap(
        Map<String, Object?>.from(item as Map),
      );
    }).toList();
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final jsonString = jsonEncode(
      tasks.map((task) => task.toMap()).toList(),
    );

    await _preferences.setString(_storageKey, jsonString);
  }

  Future<int> createTask(String title) async {
    final cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    final tasks = _readTasks();

    final nextId = tasks.isEmpty
        ? 1
        : tasks.map((task) => task.id).reduce((a, b) => a > b ? a : b) + 1;

    tasks.add(
      Task(
        id: nextId,
        title: cleanedTitle,
        isCompleted: false,
      ),
    );

    await _saveTasks(tasks);
    return nextId;
  }

  Future<List<Task>> getAllTasks() async {
    final tasks = _readTasks();
    tasks.sort((a, b) => b.id.compareTo(a.id));
    return tasks;
  }

  Future<int> setCompleted(int id, bool completed) async {
    final tasks = _readTasks();
    final index = tasks.indexWhere((task) => task.id == id);

    if (index == -1) return 0;

    tasks[index] = Task(
      id: tasks[index].id,
      title: tasks[index].title,
      isCompleted: completed,
    );

    await _saveTasks(tasks);
    return 1;
  }

  Future<int> deleteTask(int id) async {
    final tasks = _readTasks();
    final originalLength = tasks.length;

    tasks.removeWhere((task) => task.id == id);

    if (tasks.length == originalLength) return 0;

    await _saveTasks(tasks);
    return 1;
  }

  Future<void> close() async {
    // No database connection needs to be closed.
  }
}
