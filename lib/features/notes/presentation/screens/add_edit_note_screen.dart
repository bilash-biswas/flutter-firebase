import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_firebase/features/notes/domain/entities/note.dart';
import 'package:flutter_firebase/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_firebase/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter_firebase/features/ml/presentation/providers/ml_providers.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const AddEditNoteScreen({super.key, this.noteId});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Note? _existingNote;
  bool _isLoading = false;
  bool _hasChanges = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Colour tags the user can pick for the note
  static const List<Color> _colorTags = [
    Color(0xFF6C63FF),
    Color(0xFF00D4AA),
    Color(0xFFFF6B6B),
    Color(0xFFFFB347),
    Color(0xFF74B9FF),
    Color(0xFFE17CFF),
  ];
  int _selectedColorIndex = 0;

  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);

    if (_isEditing) {
      final notes = ref.read(notesStreamProvider).value ?? [];
      _existingNote =
          notes.firstWhere((n) => n.id == widget.noteId, orElse: () => null as Note);
      if (_existingNote != null) {
        _titleController.text = _existingNote!.title;
        _contentController.text = _existingNote!.content;
      }
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showScanMenu() async {
    final task = await showModalBottomSheet<MLTask>(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Magic Scan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _ScanOption(
                icon: Icons.text_fields_rounded,
                title: 'Scan Text (OCR)',
                onTap: () => Navigator.pop(context, MLTask.ocr),
              ),
              _ScanOption(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan Barcode',
                onTap: () => Navigator.pop(context, MLTask.barcode),
              ),
              _ScanOption(
                icon: Icons.face_rounded,
                title: 'Detect Faces',
                onTap: () => Navigator.pop(context, MLTask.face),
              ),
            ],
          ),
        ),
      ),
    );

    if (task != null) {
      _processScan(task);
    }
  }

  Future<void> _processScan(MLTask task) async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(mlScannerProvider)(task);
      if (result != null && result.isNotEmpty) {
        final currentText = _contentController.text;
        _contentController.text = currentText.isEmpty ? result : '$currentText\n\n$result';
        _showSnackbar('Scan complete!');
      }
    } catch (e) {
      debugPrint('ML Scan Error: $e');
      _showSnackbar('Error scanning: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      _showSnackbar('Title and content cannot be empty.', isError: true);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      if (!_isEditing) {
        await ref.read(addNoteProvider).call(
          title: title,
          content: content,
          userId: user.uid,
        );
      } else {
        final updatedNote = Note(
          id: widget.noteId!,
          title: title,
          content: content,
          createdAt: _existingNote!.createdAt,
          userId: user.uid,
        );
        await ref.read(updateNoteProvider).call(updatedNote);
      }
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showSnackbar('Error saving note.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _DiscardDialog(),
    );
    return result ?? false;
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor:
        isError ? const Color(0xFFE53935) : const Color(0xFF00D4AA),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount => _contentController.text.length;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accentColor = _colorTags[_selectedColorIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            // Accent glow tied to selected colour tag
            Positioned(
              top: -100,
              right: -80,
              child: _GlowBlob(
                color: accentColor.withOpacity(0.22),
                size: 300,
              ),
            ),
            Positioned(
              bottom: 80,
              left: -60,
              child: _GlowBlob(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                size: 200,
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // ── Top Bar ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            // Back
                            _IconPill(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () async {
                                if (await _onWillPop()) context.go('/home');
                              },
                            ),
                            const SizedBox(width: 14),
                            // Title chip
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing ? 'Edit Note' : 'New Note',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (_isEditing && _existingNote != null)
                                    Text(
                                      'Last edited · ${_formatDate(_existingNote!.createdAt)}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Scan Text
                            _IconPill(
                              icon: Icons.auto_awesome_rounded, // Changed to a "magic" icon
                              onTap: _showScanMenu,
                            ),
                            const SizedBox(width: 14),
                            // Save button
                            _SaveButton(
                              isLoading: _isLoading,
                              hasChanges: _hasChanges,
                              accentColor: accentColor,
                              onTap: _save,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Colour Tag Picker ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              'TAG',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 14),
                            ...List.generate(_colorTags.length, (i) {
                              final selected = _selectedColorIndex == i;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedColorIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  width: selected ? 28 : 22,
                                  height: selected ? 28 : 22,
                                  decoration: BoxDecoration(
                                    color: _colorTags[i],
                                    shape: BoxShape.circle,
                                    border: selected
                                        ? Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 2,
                                    )
                                        : null,
                                    boxShadow: selected
                                        ? [
                                      BoxShadow(
                                        color: _colorTags[i]
                                            .withOpacity(0.5),
                                        blurRadius: 10,
                                      )
                                    ]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Main Editor ───────────────────────────────
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                // Title field
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 20, 20, 0),
                                  child: TextField(
                                    controller: _titleController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      hintText: 'Note title…',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.2),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),

                                // Divider
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.07),
                                    height: 1,
                                  ),
                                ),

                                // Content field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 12),
                                    child: TextField(
                                      controller: _contentController,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 15,
                                        height: 1.7,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical:
                                      TextAlignVertical.top,
                                      decoration: InputDecoration(
                                        hintText:
                                        'Start writing your thoughts…',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.18),
                                          fontSize: 15,
                                          height: 1.7,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Stats Bar ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        child: Row(
                          children: [
                            _StatChip(
                                label: '$_wordCount words',
                                icon: Icons.text_fields_rounded),
                            const SizedBox(width: 10),
                            _StatChip(
                                label: '$_charCount chars',
                                icon: Icons.notes_rounded),
                            const Spacer(),
                            if (_hasChanges)
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Unsaved',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 8
                              : 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ─── Discard Dialog ──────────────────────────────────────────────────────────

class _DiscardDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141420),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discard changes?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have unsaved changes. If you go back now, they will be lost.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.12)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Keep editing',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Discard',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small Widgets ───────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white60, size: 16),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool hasChanges;
  final Color accentColor;
  final VoidCallback onTap;
  const _SaveButton({
    required this.isLoading,
    required this.hasChanges,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: hasChanges ? accentColor : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasChanges
                ? Colors.transparent
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: hasChanges
              ? [
            BoxShadow(
              color: accentColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              color: hasChanges
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Save',
              style: TextStyle(
                color: hasChanges
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.28),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ScanOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ScanOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
    );
  }
}