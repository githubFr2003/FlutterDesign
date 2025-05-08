import 'package:flutter/material.dart';
import 'package:flutter_activity/models/task.dart';
import 'package:flutter_activity/services/task_service.dart';
import 'package:flutter_activity/screens/home/add_edit_task_screen.dart';
import 'package:intl/intl.dart';

class TaskInfoScreen extends StatelessWidget {
  final Task task;
  const TaskInfoScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.isCompleted;
    final statusColor = isCompleted ? Colors.green : Colors.orange;
    final statusText = isCompleted ? 'Completed' : 'Pending';
    final statusIcon = isCompleted ? Icons.check_circle : Icons.pending_actions;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 28),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(statusText, style: TextStyle(color: Colors.white)),
                              backgroundColor: statusColor,
                            ),
                            const Spacer(),
                            Icon(
                              task.priority == TaskPriority.high
                                  ? Icons.priority_high
                                  : task.priority == TaskPriority.medium
                                      ? Icons.trending_up
                                      : Icons.low_priority,
                              color: task.priority == TaskPriority.high
                                  ? Colors.red
                                  : task.priority == TaskPriority.medium
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
                              style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          task.title,
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                        Text(
                          'Description',
                          style: textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (task.description != null && task.description!.isNotEmpty)
                                ? task.description!
                                : 'No description provided.',
                            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Created: ',
                              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
                            ),
                            Text(
                              DateFormat.yMMMd().add_jm().format(task.createdAt),
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.event, color: colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Due: ',
                                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
                              ),
                              Text(
                                DateFormat.yMMMd().format(task.dueDate!),
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        await TaskService.markTaskAsDone(task.id);
                        await TaskService.showSuccessDialog(context, 'Task marked as complete!');
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                if (!isCompleted) const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Task'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditTaskScreen(taskToEdit: task),
                        ),
                      );
                      if (result != null) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 