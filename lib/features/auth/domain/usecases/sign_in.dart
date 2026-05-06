import 'package:flutter_firebase/features/auth/domain/entities/user.dart';
import 'package:flutter_firebase/features/auth/domain/repository/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}
