import 'package:flutter_firebase/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<bool> reloadAndCheckVerified();
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> signInWithGoogle();
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(Exception e) verificationFailed,
  });
  Future<AppUser> signInWithPhoneCredential(String verificationId, String smsCode);
}