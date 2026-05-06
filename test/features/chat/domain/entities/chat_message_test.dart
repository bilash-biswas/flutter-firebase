import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_firebase/features/chat/data/models/message_model.dart';

void main() {
  group('ChatMessage & MessageModel Tests', () {
    test('MessageModel toJson returns a valid map', () {
      final now = DateTime.now();
      final model = MessageModel(
        id: 'msg123',
        senderId: 'user1',
        senderName: 'John Doe',
        text: 'Hello world',
        timestamp: now,
      );

      final json = model.toJson();

      expect(json['senderId'], 'user1');
      expect(json['senderName'], 'John Doe');
      expect(json['text'], 'Hello world');
      expect(json['timestamp'], now.millisecondsSinceEpoch);
    });

    test('ChatMessage properties are assigned correctly', () {
      final now = DateTime.now();
      final msg = ChatMessage(
        id: 'msg123',
        senderId: 'user1',
        senderName: 'John Doe',
        text: 'Hello world',
        timestamp: now,
      );

      expect(msg.id, 'msg123');
      expect(msg.senderId, 'user1');
      expect(msg.senderName, 'John Doe');
      expect(msg.text, 'Hello world');
      expect(msg.timestamp, now);
    });
  });
}
