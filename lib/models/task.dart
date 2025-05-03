// Keep TaskPriority enum from previous version
enum TaskPriority { low, medium, high }

class Task {
  final String id; // Still useful for local list manipulation
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
  });

  // --- Add a static helper for dummy data generation ---
  static List<Task> generateDummyTasks() {
    final now = DateTime.now();
    return [
      Task(id: '1', title: 'Buy groceries for the week', createdAt: now.subtract(const Duration(hours: 2)), priority: TaskPriority.high, dueDate: now.add(const Duration(days: 1))),
      Task(id: '2', title: 'Finish TaskFlow UI design', createdAt: now.subtract(const Duration(days: 1)), priority: TaskPriority.high, isCompleted: false),
      Task(id: '3', title: 'Call plumber about leak', createdAt: now.subtract(const Duration(hours: 5)), priority: TaskPriority.medium, isCompleted: false, dueDate: now),
      Task(id: '4', title: 'Plan weekend trip', createdAt: now.subtract(const Duration(days: 2)), priority: TaskPriority.low, isCompleted: true),
      Task(id: '5', title: 'Read chapter 5 of Flutter book', createdAt: now.subtract(const Duration(days: 3)), priority: TaskPriority.medium, isCompleted: true, dueDate: now.subtract(const Duration(days: 1))),
      Task(id: '6', title: 'Schedule team meeting', createdAt: now.subtract(const Duration(hours: 1)), priority: TaskPriority.medium, isCompleted: false, dueDate: now.add(const Duration(days: 2))),
      Task(id: '7', title: 'Water the plants', createdAt: now.subtract(const Duration(days: 4)), priority: TaskPriority.low, isCompleted: false),
    ];
  }
}