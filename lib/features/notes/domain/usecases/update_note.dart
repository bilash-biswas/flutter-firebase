import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';
import 'package:flutter_firebase/features/notes/domain/entities/note.dart';

class UpdateNote {
  final NotesRepository repository;

  UpdateNote(this.repository);

  Future<void> call(Note note) async {
    final updateNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      userId: note.userId,
      createdAt: note.createdAt,
    );
    return repository.updateNote(updateNote);
  }
}
