
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _storageKey = 'pocketplan_tasks';

  // Load saved tasks
  static Future<List<StudyTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_storageKey);

    // First launch: insert four default tasks
    if (savedData == null) {
      final tasks = StudyTask.initialTasks();
      await saveTasks(tasks);
      return tasks;
    }

    // Existing data, including an intentionally empty list
    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => StudyTask.fromJson(item))
        .toList();
  }

  // Save every change immediately
  static Future<void> saveTasks(List<StudyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encodedData);
  }
}
