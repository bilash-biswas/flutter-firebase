import 'package:flutter/material.dart';
import 'package:flutter_firebase/core/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps any screen and shows a slim offline banner at the top when offline.
class OfflineAwareScaffold extends ConsumerWidget {
  final Widget child;
  const OfflineAwareScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 36,
          color: const Color(0xFFE53935),
          child: isOnline
              ? const SizedBox.shrink()
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
