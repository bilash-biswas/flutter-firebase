import 'package:flutter_firebase/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter_firebase/features/auth/domain/entities/user.dart';
import 'package:flutter_firebase/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> get authStateChanges {
    return _dataSource.authStateChanges.map((fbUser) {
      if (fbUser == null) return null;
      return AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? fbUser.phoneNumber ?? '',
        displayName: fbUser.displayName,
      );
    });
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cred = await _dataSource.signInWithEmail(email, password);
    final fbUser = cred.user!;
    return AppUser(
      uid: fbUser.uid,
      email: fbUser.email!,
      displayName: fbUser.displayName,
    );
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<AppUser> signUpWithEmail(String email, String password) async {
    final cred = await _dataSource.signUpWithEmail(email, password);
    final fbUser = cred.user!;
    // Send verification email immediately after sign-up
    await _dataSource.sendEmailVerification();
    return AppUser(uid: fbUser.uid, email: fbUser.email!, displayName: fbUser.displayName);
  }

  @override
  Future<void> sendEmailVerification() => _dataSource.sendEmailVerification();

  @override
  Future<bool> reloadAndCheckVerified() => _dataSource.reloadAndCheckVerified();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _dataSource.sendPasswordResetEmail(email);

  @override
  Future<AppUser> signInWithGoogle() async {
    final cred = await _dataSource.signInWithGoogle();
    final fbUser = cred.user!;
    return AppUser(
      uid: fbUser.uid,
      email: fbUser.email ?? '', // Google users usually have emails
      displayName: fbUser.displayName,
    );
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(Exception e) verificationFailed,
  }) {
    return _dataSource.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: (e) => verificationFailed(e),
    );
  }

  @override
  Future<AppUser> signInWithPhoneCredential(String verificationId, String smsCode) async {
    final cred = await _dataSource.signInWithPhoneCredential(verificationId, smsCode);
    final fbUser = cred.user!;
    return AppUser(
      uid: fbUser.uid,
      email: fbUser.email ?? '', // Phone users might not have emails attached initially
      displayName: fbUser.displayName,
    );
  }
}
