import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/features/notes/domain/entities/note.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String userId;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  Note toDomain() => Note(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt,
    userId: userId,
  );

  factory NoteModel.fromDomain(Note note) => NoteModel(
    id: note.id,
    title: note.title,
    content: note.content,
    createdAt: note.createdAt,
    userId: note.userId,
  );
}
