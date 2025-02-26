class Task {
  final String name;
  final String priority;
  final String deadline;
  final int duration;

  Task({required this.name, required this.priority, required this.deadline, required this.duration});

  @override
  String toString() {
    return 'Task{name: $name, priority: $priority, deadline: $deadline, duration: $duration}';
  }
}