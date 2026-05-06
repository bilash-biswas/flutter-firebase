import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter_firebase/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_firebase/features/auth/domain/entities/user.dart';
import 'package:flutter_firebase/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_firebase/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_firebase/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_firebase/features/auth/domain/usecases/sign_up.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final signInProvider = Provider<SignIn>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignIn(repo);
});

final signUpProvider = Provider<SignUp>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignUp(repo);
});

final signOutProvider = Provider<SignOut>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignOut(repo);
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

final sendEmailVerificationProvider = Provider<Future<void> Function()>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return () => repo.sendEmailVerification();
});

final reloadVerifiedProvider = Provider<Future<bool> Function()>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return () => repo.reloadAndCheckVerified();
});

final passwordResetProvider = Provider<Future<void> Function(String)>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return (email) => repo.sendPasswordResetEmail(email);
});

final signInWithGoogleProvider = Provider<Future<AppUser> Function()>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return () => repo.signInWithGoogle();
});

class PhoneAuthState {
  final String? verificationId;
  final bool isLoading;
  final String? error;
  final bool codeSent;
  final bool isSuccess;

  PhoneAuthState({
    this.verificationId,
    this.isLoading = false,
    this.error,
    this.codeSent = false,
    this.isSuccess = false,
  });

  PhoneAuthState copyWith({
    String? verificationId,
    bool? isLoading,
    String? error,
    bool? codeSent,
    bool? isSuccess,
  }) {
    return PhoneAuthState(
      verificationId: verificationId ?? this.verificationId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      codeSent: codeSent ?? this.codeSent,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class PhoneAuthNotifier extends Notifier<PhoneAuthState> {
  @override
  PhoneAuthState build() {
    return PhoneAuthState();
  }

  void reset() {
    state = PhoneAuthState();
  }

  Future<void> verifyPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            codeSent: true,
          );
        },
        verificationFailed: (e) {
          state = state.copyWith(isLoading: false, error: e.toString());
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Verification ID is missing. Please request a new code.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithPhoneCredential(state.verificationId!, smsCode);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final phoneAuthProvider = NotifierProvider<PhoneAuthNotifier, PhoneAuthState>(() {
  return PhoneAuthNotifier();
});

class CustomUserProfile {
  final String bio;
  final String location;

  const CustomUserProfile({this.bio = '', this.location = ''});

  factory CustomUserProfile.fromMap(Map<Object?, Object?> map) {
    return CustomUserProfile(
      bio: map['bio'] as String? ?? '',
      location: map['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'location': location,
    };
  }
}

final customUserProfileStreamProvider = StreamProvider<CustomUserProfile>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Stream.value(const CustomUserProfile());
  }

  final dbRef = FirebaseDatabase.instance.ref('users/${currentUser.uid}');
  return dbRef.onValue.map((event) {
    final data = event.snapshot.value;
    if (data is Map) {
      return CustomUserProfile.fromMap(data);
    }
    return const CustomUserProfile();
  });
});

final updateCustomUserProfileProvider = Provider<Future<void> Function(CustomUserProfile)>((ref) {
  final currentUser = ref.read(currentUserProvider);
  return (profile) async {
    if (currentUser == null) return;
    final dbRef = FirebaseDatabase.instance.ref('users/${currentUser.uid}');
    await dbRef.set(profile.toMap());
  };
});
