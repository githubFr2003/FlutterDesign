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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Card(
        key: ValueKey(task.id + task.isCompleted.toString()),
        clipBehavior: Clip.antiAlias,
        child: Dismissible(
          key: Key(task.id),
          background: Container(
            color: Colors.green.shade400,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            child: Icon(Icons.check_circle, color: Colors.white, size: 32),
          ),
          secondaryBackground: Container(
            color: colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete_sweep_outlined, color: colorScheme.onErrorContainer, size: 32),
          ),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd && !task.isCompleted) {
              // Swipe right to complete
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Mark as Complete?'),
                  content: const Text('Do you want to mark this task as complete?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              );
            } else if (direction == DismissDirection.endToStart) {
              // Swipe left to delete
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd && !task.isCompleted) {
              onStatusChanged(true);
            } else if (direction == DismissDirection.endToStart) {
              onDelete();
            }
          },
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                // --- Priority Indicator Bar ---
                Container(
                  width: 6.0,
                  height: 75,
                  color: task.isCompleted ? Colors.grey.shade400 : _getPriorityColor(context),
                ),
                // --- Checkbox ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: onStatusChanged,
                  ),
                ),
                // --- Main Content ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0).copyWith(right: 8),
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
                                    DateFormat.MMMd().format(task.dueDate!),
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
                  padding: const EdgeInsets.all(12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}