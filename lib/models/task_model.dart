
class StudyTask {
  final String id;
  final String title;
  final String subject;
  final int plannedDay;
  final bool isDone;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.plannedDay,
    this.isDone = false,
  });

  // Convert task into JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'planned_day': plannedDay,
      'done': isDone,
    };
  }

  // Convert JSON back into task
  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      plannedDay: json['planned_day'],
      isDone: json['done'] ?? false,
    );
  }

  // Create updated copy of a task
  StudyTask copyWith({
    String? title,
    String? subject,
    int? plannedDay,
    bool? isDone,
  }) {
    return StudyTask(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      plannedDay: plannedDay ?? this.plannedDay,
      isDone: isDone ?? this.isDone,
    );
  }

  // Initial four tasks from internship brief
  static List<StudyTask> initialTasks() {
    return [
      StudyTask(
        id: '1',
        title: 'Algebra',
        subject: 'Maths',
        plannedDay: 2,
      ),
      StudyTask(
        id: '2',
        title: 'Read brief',
        subject: 'Design',
        plannedDay: 3,
      ),
      StudyTask(
        id: '3',
        title: 'Python exercises',
        subject: 'Code',
        plannedDay: 2,
      ),
      StudyTask(
        id: '4',
        title: 'Revise notes',
        subject: 'Maths',
        plannedDay: 4,
      ),
    ];
  }
}
