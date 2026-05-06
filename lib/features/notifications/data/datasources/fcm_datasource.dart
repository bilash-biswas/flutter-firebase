import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMDataSource {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<NotificationSettings> requestPermission() {
    return _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() => _fcm.getToken();

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() => _fcm.getInitialMessage();

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    // Handle background message
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }
}
