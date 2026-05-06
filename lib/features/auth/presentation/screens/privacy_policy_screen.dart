import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(color: const Color(0xFF6C63FF).withOpacity(0.1), size: 280),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── AppBar ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white60, size: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Content ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: const [
                      _SectionTitle('Last Updated: May 2026'),
                      _Body(
                        'Welcome to Flutter Firebase App. This Privacy Policy explains how we collect, use, and protect your information when you use our application.',
                      ),
                      _SectionTitle('1. Information We Collect'),
                      _Body(
                        '• Email address and display name (via Firebase Authentication)\n'
                        '• Notes content you create within the app\n'
                        '• Chat messages sent in the global chat\n'
                        '• Device token for push notifications (FCM)\n'
                        '• App usage data via Firebase Analytics (anonymized)',
                      ),
                      _SectionTitle('2. How We Use Your Information'),
                      _Body(
                        '• To authenticate you and manage your account\n'
                        '• To store and sync your notes across devices\n'
                        '• To deliver push notifications you have opted in to\n'
                        '• To improve app stability via crash reports (Crashlytics)\n'
                        '• To send you account-related emails (verification, password reset)',
                      ),
                      _SectionTitle('3. Data Storage'),
                      _Body(
                        'Your data is stored securely on Google Firebase servers. Notes are stored in Firestore. Chat messages are stored in Firebase Realtime Database. All data is protected by Firebase Security Rules ensuring only you can access your own notes.',
                      ),
                      _SectionTitle('4. Data Sharing'),
                      _Body(
                        'We do not sell, trade, or share your personal data with third parties. Your data is only shared with Google Firebase as the underlying infrastructure provider, subject to Google\'s Privacy Policy.',
                      ),
                      _SectionTitle('5. Chat Messages'),
                      _Body(
                        'Messages sent in the Global Chat are visible to all authenticated users of this application. Do not share sensitive or personal information in the chat.',
                      ),
                      _SectionTitle('6. Push Notifications'),
                      _Body(
                        'You can disable push notifications at any time through your device settings. Disabling notifications does not affect your ability to use the app.',
                      ),
                      _SectionTitle('7. Your Rights'),
                      _Body(
                        '• Access your personal data\n'
                        '• Delete your account and all associated data\n'
                        '• Opt out of analytics (via device settings)\n'
                        '• Opt out of push notifications',
                      ),
                      _SectionTitle('8. Contact Us'),
                      _Body(
                        'If you have any questions about this Privacy Policy, please contact us at support@flutterfirebase.app.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 13,
        height: 1.7,
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: const SizedBox.expand()),
    );
  }
}
