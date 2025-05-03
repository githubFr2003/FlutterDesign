import 'package:flutter/material.dart';
import 'package:flutter_activity/models/task.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?) onStatusChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onTap,
    required this.onDelete,
  });

  // Helper to get priority color
  Color _getPriorityColor(BuildContext context) {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade600;
      case TaskPriority.low:
        return const Color.fromARGB(255, 0, 255, 0); // Use a theme color or specific one
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));

    // Define text style for completed tasks
    final completedTextStyle = TextStyle(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey.shade500,
    );
    final defaultTextStyle = TextStyle(color: colorScheme.onSurface);

    return Card( // Use CardTheme from AppTheme
      clipBehavior: Clip.antiAlias, // Ensure priority bar clips correctly
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          color: colorScheme.errorContainer,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: Icon(Icons.delete_sweep_outlined, color: colorScheme.onErrorContainer),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => onDelete(),
        // Add confirmDismiss dialog if desired (as in previous Firebase version)
        child: InkWell( // Make the whole area tappable
          onTap: onTap,
          child: Row(
            children: [
              // --- Priority Indicator Bar ---
              Container(
                width: 6.0, // Width of the bar
                height: 75, // Estimate height or calculate dynamically if needed
                color: task.isCompleted ? Colors.grey.shade400 : _getPriorityColor(context),
              ),
              // --- Checkbox ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: onStatusChanged,
                  // Style from CheckboxTheme
                ),
              ),
              // --- Main Content ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0).copyWith(right: 8), // Adjust padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Title ---
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (task.isCompleted ? completedTextStyle : defaultTextStyle).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // --- Optional Description ---
                      if (task.description != null && task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (task.isCompleted ? completedTextStyle : defaultTextStyle).copyWith(
                              fontSize: 13.5,
                              color: task.isCompleted ? Colors.grey.shade500 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      // --- Due Date ---
                      if (task.dueDate != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 6.0),
                           child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                   Icons.calendar_today_outlined,
                                   size: 15,
                                   color: isOverdue ? colorScheme.error : Colors.grey.shade600
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat.MMMd().format(task.dueDate!), // Shorter date format
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isOverdue ? colorScheme.error : Colors.grey.shade600,
                                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                           ),
                         ),
                    ],
                  ),
                ),
              ),
              // --- Delete Button ---
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
                onPressed: onDelete,
                tooltip: 'Delete Task',
                padding: const EdgeInsets.all(12), // Ensure decent tap area
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}