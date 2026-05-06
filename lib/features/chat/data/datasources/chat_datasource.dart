import 'package:firebase_database/firebase_database.dart';

const int kPageSize = 20;

class ChatDataSource {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference get _messagesRef => _db.ref('messages');

  /// Streams the last [kPageSize] messages, live updating.
  Stream<DatabaseEvent> watchMessages({int limit = kPageSize}) {
    return _messagesRef.orderByKey().limitToLast(limit).onValue;
  }

  /// Fetches [kPageSize] messages older than [beforeKey] for pagination.
  Future<DataSnapshot> fetchBefore(String beforeKey) {
    return _messagesRef
        .orderByKey()
        .endBefore(beforeKey)
        .limitToLast(kPageSize)
        .get();
  }

  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    await _messagesRef.push().set(messageData);
  }
}
