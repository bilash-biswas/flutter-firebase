class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String userId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
  });
}
