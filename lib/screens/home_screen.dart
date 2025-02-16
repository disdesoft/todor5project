import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todor5/screens/add_task_screen.dart';
import 'package:todor5/screens/edit_task_screen.dart';
import 'package:todor5/screens/login_screen.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, bool> _translateState = {};
  bool _showCompletedTasks = false;

  String formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM", 'es_ES').format(date);
  }

  void _toggleTaskCompletion(Task task) {
    _firestoreService.updateTaskCompletion(task.id, !task.isCompleted);
    setState(() {});
  }

  void _signOut() async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()), 
    (Route<dynamic> route) => false, 
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6faf9),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'R5 Tasks',
            style: TextStyle(
              fontFamily: 'EloquiaDisplay',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFe6faf9),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _signOut,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskScreen()),
              );
            },
          ),
        ],
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
          for (var task in tasks.where((task) => !task.isCompleted)) {
            String formattedDate = formatDate(task.date);
            if (!groupedTasks.containsKey(formattedDate)) {
              groupedTasks[formattedDate] = [];
            }
            groupedTasks[formattedDate]!.add(task);
          }

          List<Task> completedTasks = tasks.where((task) => task.isCompleted).toList();

          return ListView(
            children: [
              ...groupedTasks.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.atkinsonHyperlegible(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ...entry.value.map((task) => _buildTaskItem(task)).toList(),
                  ],
                );
              }).toList(),
              if (completedTasks.isNotEmpty)
                ListTile(
                  title: Text(
                    'Tareas Completadas (${completedTasks.length})',
                    style: GoogleFonts.atkinsonHyperlegible(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _showCompletedTasks ? Icons.expand_less : Icons.expand_more,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCompletedTasks = !_showCompletedTasks;
                      });
                    },
                  ),
                ),
              if (_showCompletedTasks)
                ...completedTasks.map((task) => _buildTaskItem(task)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    _translateState.putIfAbsent(task.id, () => false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _translateState[task.id]! ? task.translatedTitle : task.title,
            style: GoogleFonts.atkinsonHyperlegible(
              textStyle: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _translateState[task.id]! ? task.translatedDescription : task.description,
            style: GoogleFonts.atkinsonHyperlegible(
              textStyle: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _translateState[task.id] = !_translateState[task.id]!;
              });
            },
            child: Text(
              'Translate',
              style: GoogleFonts.atkinsonHyperlegible(
                textStyle: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                checkColor: Colors.white,
                value: task.isCompleted,
                onChanged: (value) {
                  _toggleTaskCompletion(task);
                },
                activeColor: Colors.green,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _firestoreService.deleteTask(task.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
