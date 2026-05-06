import 'package:flutter_firebase/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_firebase/features/notes/presentation/screens/add_edit_note_screen.dart';
import 'package:flutter_firebase/features/notes/presentation/screens/home_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:flutter_firebase/features/auth/presentation/screens/profile_screen.dart';
import 'package:flutter_firebase/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.value;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;

      final isAuthRoute = location.startsWith('/sign');
      final isPublicRoute = location == '/' || location == '/onboarding';
      final isVerifyRoute = location == '/verify-email';
      final isPhoneRoute = location.startsWith('/phone');

      if (isLoading && isPublicRoute) return null;
      if (isLoading) return '/';

      // Logged in but email not verified → go to verify screen
      // NOTE: AppUser doesn't carry isEmailVerified, so we skip this check here.
      // The sign-up screen handles the redirect to /verify-email directly.

      if (!isLoggedIn && !isAuthRoute && !isPublicRoute && !isVerifyRoute && !isPhoneRoute) return '/sign-in';
      if (isLoggedIn && (isAuthRoute || isPhoneRoute)) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const EmailVerificationScreen()),
      GoRoute(path: '/privacy-policy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: '/phone-sign-in', builder: (_, __) => const PhoneSignInScreen()),
      GoRoute(path: '/phone-verify', builder: (_, __) => const PhoneVerificationScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/add-note', builder: (_, __) => const AddEditNoteScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/edit-note/:noteId',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId']!;
          return AddEditNoteScreen(noteId: noteId);
        },
      ),
    ],
  );
});