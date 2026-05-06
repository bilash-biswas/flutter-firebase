import 'package:flutter_firebase/features/notes/domain/entities/note.dart';
import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';
import 'package:uuid/uuid.dart';

class AddNote {
  final NotesRepository repository;

  AddNote(this.repository);

  Future<void> call({
    required String title,
    required String content,
    required String userId,
  }) async {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
    );
    return repository.addNote(note);
  }
}
