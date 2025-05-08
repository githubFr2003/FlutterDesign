import 'package:flutter/material.dart';
import 'package:flutter_activity/models/task.dart'; 
import 'package:flutter_activity/screens/auth/login_screen.dart';
import 'package:flutter_activity/screens/home/add_edit_task_screen.dart';
import 'package:flutter_activity/widgets/task_tile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_activity/services/task_service.dart';
import 'package:flutter_activity/screens/home/task_info_screen.dart';
import 'package:flutter_activity/screens/home/settings_screen.dart';

// Enums for filter/sort (keep for UI state)
enum TaskFilter { all, pending, completed, dueToday }
enum TaskSort { createdAt, dueDate, priority }

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State for UI Control (Filters, Sort, Search) ---
  TaskFilter _currentFilter = TaskFilter.pending;
  TaskSort _currentSort = TaskSort.createdAt;
  bool _sortDescending = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  final bool _isLoading = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();

    // Keep search listener to update the query state, but it won't filter locally
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
          // TODO: Trigger backend search/filter based on _searchQuery, _currentFilter, _currentSort
          print("Search Query Changed: $_searchQuery"); // Placeholder action 
        });
      }
    });

  }

  @override
  void dispose() {  // Dispose of the search controller to avoid memory leaks
    _searchController.removeListener(() {}); // Remove listener to avoid memory leaks
    _searchController.dispose(); // Dispose of the controller
    super.dispose();
  }

  // --- Update Filter/Sort State (Modified) ---
  void _setFilter(TaskFilter filter) {
    setState(() {
      _currentFilter = filter;
      // TODO: Trigger backend refetch/filter based on new filter
      print("Filter Changed: $_currentFilter"); // Placeholder action
      
    });
  }

  void _setSort(TaskSort sort) {
    setState(() {
      if (_currentSort == sort) {
        _sortDescending = !_sortDescending; // Toggle direction
      } else {
        _currentSort = sort;
        _sortDescending = (sort == TaskSort.createdAt || sort == TaskSort.priority);
      }
      // TODO: Trigger backend refetch/sort based on new sort order
      print("Sort Changed: $_currentSort, Descending: $_sortDescending"); // Placeholder action
      
    });
  }

  // --- Navigation (Modified Result Handling) ---
  void _navigateToAddTaskScreen() async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
    );
    if (result != null) {
      // TODO: Send the 'result' (new task) to the backend
      print("Task Added (Placeholder): ${result.title}");
      // TODO: Refetch tasks list from backend or update state optimistically
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "${result.title}" sent to backend (simulated).'), backgroundColor: Colors.green),
      );
    }
  }

  void _navigateToEditTaskScreen(Task task) async {
    // If using static examples, create a real Task object for editing
     final taskToEdit = Task(
       id: task.id, // Use the ID from the static example
       title: task.title,
       description: task.description,
       createdAt: task.createdAt,
       dueDate: task.dueDate,
       priority: task.priority,
       isCompleted: task.isCompleted,
     );

    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (context) => AddEditTaskScreen(taskToEdit: taskToEdit)),
    );
    if (result != null) {
      // TODO: Send the 'result' (updated task) to the backend
       print("Task Updated (Placeholder): ${result.title}");
      // TODO: Refetch tasks list from backend or update state optimistically
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Task "${result.title}" update sent to backend (simulated).')),
       );
      // _updateTask(result); // REMOVED
    }
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 8),
              const Text('Success', textAlign: TextAlign.center),
            ],
          ),
          content: const Text('Logged out successfully!', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
            onSignOut: widget.onSignOut,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- Filter Chip Builder (UI only) ---
  // This method creates a filter chip for the task filter options 
  // It takes a TaskFilter enum value, a label for the chip, and an optional icon.
  // The chip is selected based on the current filter state and updates the filter when tapped.
  Widget _buildFilterChip(TaskFilter filter, String label, IconData? icon) {
     final isSelected = _currentFilter == filter;
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 4.0),
       child: FilterChip(
         label: Text(label),
         avatar: icon != null ? Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.onTertiaryContainer : Colors.grey.shade600) : null,
         selected: isSelected,
         onSelected: (_) => _setFilter(filter), 
       ),
     );
  }

  // --- Placeholder Actions for TaskTile ---
  void _handleStatusChange(String taskId, bool currentStatus) {
     // TODO: Call backend to toggle task status for taskId
     print("Toggle Status (Placeholder): ID $taskId, New Status: ${!currentStatus}");
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Task status toggle sent to backend (simulated).')),
     );
  }

  Future<void> _handleDelete(String taskId, String taskTitle) async {
    await TaskService.deleteTask(taskId);
    await TaskService.showSuccessDialog(context, 'Task deleted successfully!');
  }

  // --- Build Method (Modified List View) ---
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('TaskFlow'),
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<TaskSort>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: "Sort Tasks",
              onSelected: _setSort,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskSort>>[
                PopupMenuItem<TaskSort>(
                  value: TaskSort.createdAt,
                  child: ListTile(
                    leading: Icon(_currentSort == TaskSort.createdAt ? Icons.check : null, color: colorScheme.primary),
                    title: const Text('Date Created'),
                    trailing: _currentSort == TaskSort.createdAt ? Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, size: 18) : null,
                  ),
                ),
                PopupMenuItem<TaskSort>(
                  value: TaskSort.dueDate,
                  child: ListTile(
                    leading: Icon(_currentSort == TaskSort.dueDate ? Icons.check : null, color: colorScheme.primary),
                    title: const Text('Due Date'),
                    trailing: _currentSort == TaskSort.dueDate ? Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, size: 18) : null,
                  ),
                ),
                PopupMenuItem<TaskSort>(
                  value: TaskSort.priority,
                  child: ListTile(
                    leading: Icon(_currentSort == TaskSort.priority ? Icons.check : null, color: colorScheme.primary),
                    title: const Text('Priority'),
                    trailing: _currentSort == TaskSort.priority ? Icon(_sortDescending ? Icons.arrow_downward : Icons.arrow_upward, size: 18) : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                    onSignOut: widget.onSignOut,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Filter/Search Bar (modern Card) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: colorScheme.primary),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(TaskFilter.pending, 'Pending', Icons.pending_actions_outlined),
                            _buildFilterChip(TaskFilter.dueToday, 'Due Today', Icons.today_outlined),
                            _buildFilterChip(TaskFilter.completed, 'Completed', Icons.check_circle_outline),
                            _buildFilterChip(TaskFilter.all, 'All', Icons.inbox_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --- Task List (Firestore) ---
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: TaskService.getUserTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final tasks = snapshot.data ?? [];
                  final now = DateTime.now();
                  List<Task> filteredTasks = tasks;
                  switch (_currentFilter) {
                    case TaskFilter.pending:
                      filteredTasks = tasks.where((t) => !t.isCompleted).toList();
                      break;
                    case TaskFilter.completed:
                      filteredTasks = tasks.where((t) => t.isCompleted).toList();
                      break;
                    case TaskFilter.dueToday:
                      filteredTasks = tasks.where((t) =>
                        t.dueDate != null &&
                        t.dueDate!.year == now.year &&
                        t.dueDate!.month == now.month &&
                        t.dueDate!.day == now.day
                      ).toList();
                      break;
                    case TaskFilter.all:
                      // No filter
                      break;
                  }
                  if (_searchQuery.isNotEmpty) {
                    filteredTasks = filteredTasks.where((t) =>
                      t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (t.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                    ).toList();
                  }
                  // Sort the filteredTasks list
                  filteredTasks.sort((a, b) {
                    int cmp = 0;
                    switch (_currentSort) {
                      case TaskSort.createdAt:
                        cmp = a.createdAt.compareTo(b.createdAt);
                        break;
                      case TaskSort.dueDate:
                        if (a.dueDate == null && b.dueDate == null) cmp = 0;
                        else if (a.dueDate == null) cmp = 1;
                        else if (b.dueDate == null) cmp = -1;
                        else cmp = a.dueDate!.compareTo(b.dueDate!);
                        break;
                      case TaskSort.priority:
                        cmp = b.priority.index.compareTo(a.priority.index);
                        break;
                    }
                    return _sortDescending ? -cmp : cmp;
                  });
                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: colorScheme.primary.withOpacity(0.18)),
                          const SizedBox(height: 18),
                          Text(
                            'No tasks found for this filter.',
                            style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: TaskTile(
                          task: task,
                          onStatusChanged: (value) async {
                            await TaskService.toggleTaskCompleted(task.id, value ?? false);
                            if (value == true) {
                              await TaskService.showSuccessDialog(context, 'Task marked as done!');
                            }
                          },
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TaskInfoScreen(task: task),
                              ),
                            );
                          },
                          onDelete: () => _handleDelete(task.id, task.title),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
        elevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
