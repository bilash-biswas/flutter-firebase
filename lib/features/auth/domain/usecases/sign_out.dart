import 'package:flutter_firebase/features/auth/domain/repository/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() => repository.signOut();
}
