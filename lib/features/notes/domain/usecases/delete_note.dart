import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';

class DeleteNote {
  final NotesRepository repository;
  DeleteNote(this.repository);
  Future<void> call(String userId, String noteId) async {
    return repository.deleteNote(userId, noteId);
  }
}