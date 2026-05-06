import 'package:flutter_firebase/features/chat/data/datasources/chat_datasource.dart';
import 'package:flutter_firebase/features/chat/data/models/message_model.dart';
import 'package:flutter_firebase/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_firebase/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  List<ChatMessage> _snapshotToMessages(dynamic value) {
    if (value == null) return [];
    final Map<dynamic, dynamic> values = value as Map;
    final messages = <ChatMessage>[];
    values.forEach((key, val) {
      final data = Map<String, dynamic>.from(val as Map);
      messages.add(ChatMessage(
        id: key.toString(),
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? 'Unknown User',
        text: data['text'] ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      ));
    });
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  @override
  Stream<List<ChatMessage>> watchMessages({int limit = kPageSize}) {
    return _dataSource.watchMessages(limit: limit).map((event) {
      return _snapshotToMessages(event.snapshot.value);
    });
  }

  @override
  Future<List<ChatMessage>> fetchOlderMessages(String beforeKey) async {
    final snapshot = await _dataSource.fetchBefore(beforeKey);
    return _snapshotToMessages(snapshot.value);
  }

  @override
  Future<void> sendMessage(String text, String senderId, String senderName) {
    final model = MessageModel(
      id: '',
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );
    return _dataSource.sendMessage(model.toJson());
  }
}
