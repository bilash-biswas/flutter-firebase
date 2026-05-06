import 'package:flutter_firebase/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages({int limit});
  Future<List<ChatMessage>> fetchOlderMessages(String beforeKey);
  Future<void> sendMessage(String text, String senderId, String senderName);
}
