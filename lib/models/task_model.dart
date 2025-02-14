class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime date;
  final String translatedTitle;
  final String translatedDescription;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.date,
    required this.translatedTitle,
    required this.translatedDescription,
    required this.userId,
  });

  // Convertir un Task a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'date': date,
      'translatedTitle': translatedTitle,
      'translatedDescription': translatedDescription,
      'userId': userId,
    };
  }

  // Convertir un Map de Firestore a un Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      date: map['date'].toDate(),
      translatedTitle: map['translatedTitle'],
      translatedDescription: map['translatedDescription'],
      userId: map['userId'],
    );
  }
}