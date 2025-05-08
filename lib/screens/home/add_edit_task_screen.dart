import 'package:flutter/material.dart';
import 'package:flutter_activity/models/task.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_activity/services/task_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddEditTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  TaskPriority _selectedPriority = TaskPriority.medium;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedDueDate = widget.taskToEdit?.dueDate;
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    setState(() {
      _selectedDueDate = pickedDate;
    });
    }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.taskToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isCompleted: _isEditing ? widget.taskToEdit!.isCompleted : false,
        createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
      );
      if (_isEditing) {
        await TaskService.updateTask(task.id, task.toFirestore());
        await TaskService.showSuccessDialog(context, 'Task updated successfully!');
      } else {
        await TaskService.addTask(task);
        await TaskService.showSuccessDialog(context, 'Task added successfully!');
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add New Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.title, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Task Title', style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'What do you need to do?',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter a task title'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.notes, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Description', style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Add more details... (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Due Date', style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDueDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            hintText: 'Select Date (Optional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: Icon(Icons.edit_calendar, color: colorScheme.primary),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDueDate == null
                                    ? 'Not Set'
                                    : DateFormat.yMMMd().format(_selectedDueDate!),
                                style: textTheme.bodyLarge,
                              ),
                              if (_selectedDueDate != null) ...[
                                const Spacer(),
                                IconButton(
                                  icon: Icon(Icons.clear, color: colorScheme.error),
                                  onPressed: () {
                                    setState(() => _selectedDueDate = null);
                                  },
                                  tooltip: 'Clear Date',
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.flag, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Priority', style: textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: TaskPriority.values.map((priority) {
                          final isSelected = _selectedPriority == priority;
                          Color chipColor;
                          IconData chipIcon;
                          switch (priority) {
                            case TaskPriority.high:
                              chipColor = Colors.red;
                              chipIcon = Icons.priority_high;
                              break;
                            case TaskPriority.medium:
                              chipColor = Colors.orange;
                              chipIcon = Icons.trending_up;
                              break;
                            case TaskPriority.low:
                              chipColor = Colors.green;
                              chipIcon = Icons.low_priority;
                              break;
                          }
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(chipIcon, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(priority.name[0].toUpperCase() + priority.name.substring(1)),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: chipColor,
                            backgroundColor: chipColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : chipColor,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedPriority = priority);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(_isEditing ? Icons.save : Icons.add_task),
                          label: Text(_isEditing ? 'Save Changes' : 'Add Task'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _saveTask,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}