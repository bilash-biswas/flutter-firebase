import 'package:flutter_firebase/features/notes/data/datasources/notes_datasource.dart';
import 'package:flutter_firebase/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:flutter_firebase/features/notes/domain/entities/note.dart';
import 'package:flutter_firebase/features/notes/domain/repository/notes_repository.dart';
import 'package:flutter_firebase/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_firebase/features/notes/domain/usecases/delete_note.dart';
import 'package:flutter_firebase/features/notes/domain/usecases/get_notes.dart';
import 'package:flutter_firebase/features/notes/domain/usecases/update_note.dart';
import 'package:flutter_firebase/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseNotesDataSourceProvider = Provider<FirebaseNotesDataSource>((
  ref,
) {
  return FirebaseNotesDataSource();
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final ds = ref.watch(firebaseNotesDataSourceProvider);
  return NotesRepositoryImpl(ds);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return GetNotes(repo);
});

final addNoteProvider = Provider<AddNote>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return AddNote(repo);
});

final updateNoteProvider = Provider<UpdateNote>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return UpdateNote(repo);
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return DeleteNote(repo);
});

final notesStreamProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final getNotes = ref.watch(getNotesProvider);
  return getNotes(user.uid);
});
