import 'package:flutter_firebase/features/notes/data/datasources/notes_datasource.dart';
import 'package:flutter_firebase/features/notes/data/models/note_model.dart';
import 'package:flutter_firebase/features/notes/domain/entities/note.dart';
import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final FirebaseNotesDataSource _dataSource;

  NotesRepositoryImpl(this._dataSource);

  @override
  Future<void> addNote(Note note) {
    return _dataSource.addNote(NoteModel.fromDomain(note));
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    return _dataSource.deleteNote(userId, noteId);
  }

  @override
  Future<void> updateNote(Note note) {
    return _dataSource.updateNote(NoteModel.fromDomain(note));
  }

  @override
  Stream<List<Note>> watchNotes(String userId) {
    return _dataSource
        .watchNotes(userId)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  Future<void> deleteNoteWithUserId(String userId, String noteId) async {
    return _dataSource.deleteNote(userId, noteId);
  }
}
