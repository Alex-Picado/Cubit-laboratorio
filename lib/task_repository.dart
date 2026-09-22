import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección donde guardamos las tareas.
  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  // Entrega la lista inicial y las actualizaciones posteriores.
  Stream<List<Task>> watchTasks() {
    return _tasks.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        return Task(
          id: document.id,
          title: data['title'] as String,
          completed: data['completed'] as bool,
        );
      }).toList();
    });
  }

  // Crea un documento. Firestore genera su identificador.
  Future<void> addTask(String description) async {
    final title = description.trim();

    if (title.isEmpty) {
      return;
    }

    await _tasks.add({
      'title': title,
      'completed': false,
    });
  }

  // Invierte completed usando el valor actual de Firestore.
  Future<void> toggleTask(String id) async {
    final reference = _tasks.doc(id);

    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();

      // La tarea pudo haber sido eliminada desde otro dispositivo.
      if (data == null) {
        return;
      }

      final completed = data['completed'] as bool;

      transaction.update(reference, {
        'completed': !completed,
      });
    });
  }

  // Elimina el documento correspondiente a la tarea.
  Future<void> removeTask(String id) async {
    await _tasks.doc(id).delete();
  }
}