import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:todor5/screens/add_task_screen.dart';
import 'package:todor5/screens/edit_task_screen.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, bool> _translateState = {};

  String formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM", 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
          255, 207, 233, 235), // Color de fondo tomado de la imagen
      appBar: AppBar(
        title: const Text(
          'ToDo R5 (Fabián Valero)',
          style: TextStyle(
            fontFamily: 'EloquiaDisplay',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 207, 233, 235),
      ),
      body: StreamBuilder<List<Task>>(
        stream:
            _firestoreService.getTasks(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay tareas.',
                    style: TextStyle(color: Colors.white)));
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
                      style: TextStyle(
                        fontFamily: 'EloquiaDisplay',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map((task) {
                    _translateState.putIfAbsent(task.id, () => false);
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translateState[task.id]!
                                ? task.translatedTitle
                                : task.title,
                            style: TextStyle(
                              fontFamily: 'EloquiaDisplay',
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _translateState[task.id]!
                                ? task.translatedDescription
                                : task.description,
                            style: TextStyle(
                              fontFamily: 'EloquiaDisplay',
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _translateState[task.id] =
                                    !_translateState[task.id]!;
                              });
                            },
                            child: Text(
                              'Translate',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {},
                                activeColor: Colors.blue,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white70),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditTaskScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  _firestoreService.deleteTask(task.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
