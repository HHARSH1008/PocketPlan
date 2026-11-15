
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StudyTask> tasks = [];

  String selectedFilter = 'All';
  bool isLoading = true;

  final List<String> subjects = [
    'All',
    'Maths',
    'Design',
    'Code',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Load tasks from local storage
  Future<void> loadData() async {
    try {
      final savedTasks = await StorageService.loadTasks();

      if (!mounted) return;

      setState(() {
        tasks = savedTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load tasks. Please restart the app.'),
        ),
      );
    }
  }

  // Save changes
  Future<void> saveData() async {
    await StorageService.saveTasks(tasks);
  }

  // Filter tasks
  List<StudyTask> get filteredTasks {
    if (selectedFilter == 'All') {
      return tasks;
    }

    return tasks
        .where((task) => task.subject == selectedFilter)
        .toList();
  }

  int get completedTasks =>
      tasks.where((task) => task.isDone).length;

  double get progress =>
      tasks.isEmpty ? 0 : completedTasks / tasks.length;

  // Add or edit task dialog
  Future<void> showTaskDialog({StudyTask? task}) async {
    final titleController = TextEditingController(
      text: task?.title ?? '',
    );

    String selectedSubject = task?.subject ?? 'Maths';
    int selectedDay = task?.plannedDay ?? 1;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              title: Text(
                task == null ? 'Add New Task' : 'Edit Task',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Maths', 'Design', 'Code']
                          .map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            selectedSubject = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Planned Day',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(14, (index) {
                        final day = index + 1;
                        return DropdownMenuItem(
                          value: day,
                          child: Text('Day $day'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            selectedDay = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a task title'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(task == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        if (task == null) {
          final newTask = StudyTask(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: titleController.text.trim(),
            subject: selectedSubject,
            plannedDay: selectedDay,
          );

          tasks.add(newTask);

          // Clear filter if it hides the newly added task
          selectedFilter = 'All';
        } else {
          final index = tasks.indexWhere(
            (item) => item.id == task.id,
          );

          if (index != -1) {
            tasks[index] = task.copyWith(
              title: titleController.text.trim(),
              subject: selectedSubject,
              plannedDay: selectedDay,
            );
          }
        }
      });

      await saveData();

      if (task == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
          ),
        );
      }
    }

    titleController.dispose();
  }

  // Mark task done or undone
  Future<void> toggleTask(StudyTask task, bool value) async {
    final index = tasks.indexWhere(
      (item) => item.id == task.id,
    );

    if (index == -1) return;

    setState(() {
      tasks[index] = task.copyWith(isDone: value);
    });

    await saveData();
  }

  // Delete task with confirmation
  Future<void> deleteTask(StudyTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        tasks.removeWhere((item) => item.id == task.id);
      });

      await saveData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted'),
        ),
      );
    }
  }

  Color subjectColor(String subject) {
    switch (subject) {
      case 'Maths':
        return Colors.blue;
      case 'Design':
        return Colors.purple;
      case 'Code':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Task card widget
  Widget buildTaskCard(StudyTask task) {
    final color = subjectColor(task.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.isDone,
              semanticLabel: 'Mark ${task.title} as complete',
              onChanged: (value) {
                if (value != null) {
                  toggleTask(task, value);
                }
              },
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isDone
                          ? Colors.grey
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.subject,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Day ${task.plannedDay}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              tooltip: 'Task actions',
              onSelected: (value) {
                if (value == 'edit') {
                  showTaskDialog(task: task);
                } else if (value == 'delete') {
                  deleteTask(task);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PocketPlan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh tasks',
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello, Student! 👋',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Plan your study. Achieve your goals.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress card
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Completed Tasks'),
                                Text(
                                  '$completedTasks / ${tasks.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 9,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              '${(progress * 100).round()}% completed',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Filter by Subject',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subjects.map((subject) {
                        return ChoiceChip(
                          label: Text(subject),
                          selected: selectedFilter == subject,
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = subject;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Study Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredTasks.length} tasks',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    if (filteredTasks.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'No tasks found.\nAdd a new study task!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ...filteredTasks.map(buildTaskCard),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
