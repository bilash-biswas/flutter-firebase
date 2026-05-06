import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_firebase/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isUpdatingName = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editDisplayName(fb.User user) async {
    final controller = TextEditingController(text: user.displayName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text(
          'Edit Name',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF00D4AA),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUpdatingName = true);
      try {
        await user.updateDisplayName(controller.text.trim());
        await user.reload();
        // Force Riverpod auth refresh by calling reload check
        await ref.read(reloadVerifiedProvider)();
        _showToast('Display name updated successfully!');
      } catch (e) {
        _showToast('Failed to update name: $e');
      } finally {
        setState(() => _isUpdatingName = false);
      }
    }
  }

  Future<void> _editBio(CustomUserProfile profile) async {
    final controller = TextEditingController(text: profile.bio);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text(
          'Edit Bio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF00D4AA),
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final newProfile = CustomUserProfile(
          bio: controller.text.trim(),
          location: profile.location,
        );
        await ref.read(updateCustomUserProfileProvider)(newProfile);
        _showToast('Bio updated successfully!');
      } catch (e) {
        _showToast('Failed to update bio: $e');
      }
    }
  }

  Future<void> _editLocation(CustomUserProfile profile) async {
    final controller = TextEditingController(text: profile.location);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text(
          'Edit Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF00D4AA),
          decoration: InputDecoration(
            hintText: 'Enter your country/city',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final newProfile = CustomUserProfile(
          bio: profile.bio,
          location: controller.text.trim(),
        );
        await ref.read(updateCustomUserProfileProvider)(newProfile);
        _showToast('Location updated successfully!');
      } catch (e) {
        _showToast('Failed to update location: $e');
      }
    }
  }

  String _getProviderName(fb.User user) {
    if (user.providerData.isEmpty) return 'Email / Password';
    final providerId = user.providerData.first.providerId;
    if (providerId == 'google.com') return 'Google Account';
    if (providerId == 'phone') return 'SMS Phone Auth';
    return 'Email / Password';
  }

  IconData _getProviderIcon(fb.User user) {
    if (user.providerData.isEmpty) return Icons.email_rounded;
    final providerId = user.providerData.first.providerId;
    if (providerId == 'google.com') return Icons.g_mobiledata_rounded;
    if (providerId == 'phone') return Icons.phone_iphone_rounded;
    return Icons.email_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final notesAsyncValue = ref.watch(notesStreamProvider);
    final notesCount = notesAsyncValue.maybeWhen(
      data: (notes) => notes.length.toString(),
      orElse: () => '--',
    );
    final customProfileAsync = ref.watch(customUserProfileStreamProvider);
    final customProfile = customProfileAsync.value ?? const CustomUserProfile();

    if (fbUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }

    final size = MediaQuery.of(context).size;
    final joinedDate = fbUser.metadata.creationTime != null
        ? '${fbUser.metadata.creationTime!.day}/${fbUser.metadata.creationTime!.month}/${fbUser.metadata.creationTime!.year}'
        : 'Unknown';

    final initial = (fbUser.displayName != null && fbUser.displayName!.isNotEmpty)
        ? fbUser.displayName![0].toUpperCase()
        : (fbUser.email != null && fbUser.email!.isNotEmpty)
            ? fbUser.email![0].toUpperCase()
            : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -60,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFF00D4AA).withOpacity(0.15),
              size: 280,
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -70,
            child: _GlowBlob(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              size: 240,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => context.go('/home'),
                          ),
                          const Spacer(),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Spacer balance
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Avatar and Main Info
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00D4AA),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.verified_user_rounded,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              fbUser.displayName ?? 'Magic User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fbUser.email ?? fbUser.phoneNumber ?? 'No Contact Info',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Stats row
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    value: notesCount,
                                    label: 'Active Notes',
                                    icon: Icons.note_alt_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    value: joinedDate,
                                    label: 'Member Since',
                                    icon: Icons.calendar_month_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Profile Fields Glass Cards
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Column(
                                children: [
                                  _ProfileTile(
                                    icon: Icons.person_outline,
                                    label: 'Full Name',
                                    value: fbUser.displayName ?? 'Not Set',
                                    trailing: _isUpdatingName
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF00D4AA),
                                            ),
                                          )
                                        : Icon(Icons.edit_outlined,
                                            color: Colors.white.withOpacity(0.4), size: 18),
                                    onTap: () => _editDisplayName(fbUser),
                                  ),
                                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                  _ProfileTile(
                                    icon: Icons.info_outline_rounded,
                                    label: 'Bio',
                                    value: customProfile.bio.isNotEmpty ? customProfile.bio : 'Tell us about yourself...',
                                    trailing: Icon(Icons.edit_outlined,
                                        color: Colors.white.withOpacity(0.4), size: 18),
                                    onTap: () => _editBio(customProfile),
                                  ),
                                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                  _ProfileTile(
                                    icon: Icons.location_on_outlined,
                                    label: 'Location',
                                    value: customProfile.location.isNotEmpty ? customProfile.location : 'Not Set',
                                    trailing: Icon(Icons.edit_outlined,
                                        color: Colors.white.withOpacity(0.4), size: 18),
                                    onTap: () => _editLocation(customProfile),
                                  ),
                                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                  _ProfileTile(
                                    icon: _getProviderIcon(fbUser),
                                    label: 'Login Method',
                                    value: _getProviderName(fbUser),
                                  ),
                                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                  _ProfileTile(
                                    icon: Icons.fingerprint_rounded,
                                    label: 'Account UID',
                                    value: fbUser.uid,
                                    trailing: Icon(Icons.copy_rounded,
                                        color: Colors.white.withOpacity(0.4), size: 18),
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: fbUser.uid));
                                      _showToast('UID copied to clipboard!');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Modern Glass Sign Out Button
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFE53935).withOpacity(0.15),
                                    const Color(0xFFE53935).withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(color: const Color(0xFFE53935).withOpacity(0.2)),
                              ),
                              child: TextButton.icon(
                                onPressed: () async {
                                  await ref.read(signOutProvider).call();
                                  if (mounted) context.go('/sign-in');
                                },
                                icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5252), size: 20),
                                label: const Text(
                                  'Sign Out Account',
                                  style: TextStyle(
                                    color: Color(0xFFFF5252),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color(0xFF00D4AA).withOpacity(0.8), size: 20),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
