import 'package:flutter_firebase/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_firebase/features/chat/data/datasources/chat_datasource.dart';
import 'package:flutter_firebase/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_firebase/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_firebase/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatDataSourceProvider = Provider<ChatDataSource>((ref) => ChatDataSource());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final ds = ref.watch(chatDataSourceProvider);
  return ChatRepositoryImpl(ds);
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages();
});

final fetchOlderMessagesProvider =
    Provider<Future<List<ChatMessage>> Function(String)>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return (beforeKey) => repo.fetchOlderMessages(beforeKey);
});

final sendMessageProvider = Provider<Future<void> Function(String)>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  return (text) async {
    if (user == null) return;
    // displayName can be null or empty string — handle both cases
    final displayName = user.displayName;
    final emailPrefix = user.email?.split('@').first;
    final senderName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (emailPrefix != null && emailPrefix.isNotEmpty)
            ? emailPrefix
            : 'User';
    await repo.sendMessage(text, user.uid, senderName);
  };
});
