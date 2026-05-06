import 'package:flutter_firebase/features/notes/domain/entities/note.dart';
import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';

class GetNotes {
  final NotesRepository repository;

  GetNotes(this.repository);

  Stream<List<Note>> call(String userId) {
    return repository.watchNotes(userId);
  }
}
