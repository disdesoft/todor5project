import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar una tarea
  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toMap());
  }

  // Obtener tareas del usuario actual
  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId) // Filtra por userId
        .orderBy('date', descending: true)
        .orderBy('isCompleted', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    });
  }

  // Actualizar una tarea existente
  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Actualizar solo el estado de completado de una tarea
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print("Error al actualizar el estado de la tarea: $e");
    }
  }

  // Eliminar una tarea
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
