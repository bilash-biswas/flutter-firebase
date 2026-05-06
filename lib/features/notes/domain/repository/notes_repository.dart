import 'package:flutter_firebase/features/notes/domain/entities/note.dart';

abstract class NotesRepository{
  Stream<List<Note>> watchNotes(String userId);
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String userId, String noteId);
}