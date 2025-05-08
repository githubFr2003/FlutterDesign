import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'package:flutter/material.dart';

class TaskService {
  static final _firestore = FirebaseFirestore.instance;
  static CollectionReference get _taskCollection => _firestore.collection('tasks');

  static Stream<List<Task>> getUserTasksStream() {
    final user = FirebaseAuth.instance.currentUser;
    return _taskCollection
        .where('userId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  static Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    await _taskCollection.add({
      ...task.toFirestore(),
      'userId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await _taskCollection.doc(id).update(data);
  }

  static Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }

  static Future<void> showSuccessDialog(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
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
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> markTaskAsDone(String id) async {
    await _taskCollection.doc(id).update({'isCompleted': true});
  }

  static Future<void> toggleTaskCompleted(String id, bool isCompleted) async {
    await _taskCollection.doc(id).update({'isCompleted': isCompleted});
  }
}