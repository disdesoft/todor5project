import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:todor5/screens/add_task_screen.dart';
import 'package:todor5/screens/edit_task_screen.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  String formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM", 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasks(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tareas.'));
          }

          List<Task> tasks = snapshot.data!;
          tasks.sort((a, b) => a.date.compareTo(b.date));

          Map<String, List<Task>> groupedTasks = {};
          for (var task in tasks) {
            String formattedDate = formatDate(task.date);
            if (!groupedTasks.containsKey(formattedDate)) {
              groupedTasks[formattedDate] = [];
            }
            groupedTasks[formattedDate]!.add(task);
          }

          return ListView(
            children: groupedTasks.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...entry.value.map((task) => ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description),
                            const SizedBox(height: 5),
                            Text(
                              "🇺🇸 ${task.translatedTitle}",
                              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                            ),
                            Text(
                              "🇺🇸 ${task.translatedDescription}",
                              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                // Lógica para marcar como completada
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(task: task),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _firestoreService.deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                      ))
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
