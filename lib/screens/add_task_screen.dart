import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  DateTime? _selectedDate;

  // Función para seleccionar la fecha con DatePicker
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Función para guardar la tarea
  void _saveTask() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      String taskId = Uuid().v4();
      String userId = FirebaseAuth.instance.currentUser!.uid;

      Task newTask = Task(
        id: taskId,
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: false,
        date: _selectedDate!,
        translatedTitle: '',
        translatedDescription: '',
        userId: userId,
      );

      _firestoreService.addTask(newTask);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos y selecciona una fecha")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarea'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Selecciona una fecha'
                        : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Elegir Fecha'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text('Guardar Tarea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
