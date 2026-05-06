import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/features/notes/data/models/note_model.dart';

class FirebaseNotesDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoteModel>> watchNotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addNote(NoteModel note) {
    return _firestore
        .collection('users')
        .doc(note.userId)
        .collection('notes')
        .doc(note.id)
        .set(note.toFirestore());
  }

  Future<void> updateNote(NoteModel note) {
    return _firestore
        .collection('users')
        .doc(note.userId)
        .collection('notes')
        .doc(note.id)
        .update(note.toFirestore());
  }

  Future<void> deleteNote(String userId, String noteId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
