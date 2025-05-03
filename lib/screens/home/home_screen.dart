import 'package:flutter/material.dart';
import 'package:flutter_activity/models/task.dart'; 
import 'package:flutter_activity/screens/auth/login_screen.dart';
import 'package:flutter_activity/screens/home/add_edit_task_screen.dart';
import 'package:flutter_activity/widgets/task_tile.dart';

// Enums for filter/sort (keep for UI state)
enum TaskFilter { all, pending, completed, dueToday /*, dueThisWeek */ }
enum TaskSort { createdAt, dueDate, priority }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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


  bool _isLoading = false; // To show a loading indicator

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

  void _logout() {
    // Redirect to LoginScreen - Stays the same
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
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

  void _handleDelete(String taskId, String taskTitle) {
     
     // TODO: Call backend to delete task with taskId
     print("Delete Task (Placeholder): ID ");
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Task "$taskTitle" deleted.'), backgroundColor: Colors.redAccent),
     );
  }

  // --- Build Method (Modified List View) ---
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;

    // --- Static Example Tasks for Design ---
    final List<Task> staticExampleTasks = [
      Task(id: 'static-1', title: 'Design Mockups', createdAt: DateTime.now().subtract(const Duration(days: 2)), priority: TaskPriority.high, isCompleted: false, dueDate: DateTime.now().add(const Duration(days: 1))),
      Task(id: 'static-2', title: 'Setup Backend API', description: 'HEHEHEHEHE', createdAt: DateTime.now().subtract(const Duration(days: 1)), priority: TaskPriority.medium, isCompleted: false, dueDate: DateTime.now().add(const Duration(days: 5))),
      Task(id: 'static-3', title: 'Review PR #123', createdAt: DateTime.now(), priority: TaskPriority.low, isCompleted: true),
      Task(id: 'static-4', title: 'Client Meeting', createdAt: DateTime.now().subtract(const Duration(hours: 4)), priority: TaskPriority.medium, isCompleted: false, dueDate: DateTime.now().add(const Duration(hours: 2))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          // --- Sort Menu (UI only) ---
          PopupMenuButton<TaskSort>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: "Sort Tasks",
            onSelected: _setSort, // Still updates UI state
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
          // --- Logout Button ---
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
         bottom: PreferredSize( // Search Bar (UI only)
           preferredSize: const Size.fromHeight(60.0),
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
             child: TextField(
               controller: _searchController,
               decoration: InputDecoration(
                 hintText: 'Search tasks (backend)...', // Hint updated
                 prefixIcon: const Icon(Icons.search),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(25.0),
                   borderSide: BorderSide.none,
                 ),
                 filled: true,
                 fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                 suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear(); // Listener will handle state update
                        },
                      )
                    : null,
               ),
               
             ),
           ),
         ),
      ),
      body: Column(
        children: [
          // --- Filter Chips (UI only) ---
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
             child: SingleChildScrollView(
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
           ),

          // --- Task List (Static Examples) ---
          Expanded(
            child: _isLoading // Optional: Show loading indicator while fetching
              ? const Center(child: CircularProgressIndicator())
              : staticExampleTasks.isEmpty && !_isLoading // Show empty state if needed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 20),
                            Text(
                              'No tasks found', // Generic empty message
                              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a new task.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder( // Display static examples
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: staticExampleTasks.length,
                      itemBuilder: (context, index) {
                        final task = staticExampleTasks[index];
                        return TaskTile(
                          task: task,
                          // --- Connect TaskTile actions to placeholder handlers ---
                          onStatusChanged: (value) => _handleStatusChange(task.id, task.isCompleted),
                          onTap: () => _navigateToEditTaskScreen(task),
                          onDelete: () => _handleDelete(task.id, task.title),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen, // Still navigates
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
