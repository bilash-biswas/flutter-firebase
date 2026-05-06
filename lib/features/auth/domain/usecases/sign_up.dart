import 'package:flutter_firebase/features/auth/domain/entities/user.dart';
import 'package:flutter_firebase/features/auth/domain/repository/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signUpWithEmail(email, password);
  }
}
