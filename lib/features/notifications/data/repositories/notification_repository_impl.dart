import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_firebase/features/notifications/data/datasources/fcm_datasource.dart';
import 'package:flutter_firebase/features/notifications/domain/entities/notification.dart';
import 'package:flutter_firebase/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FCMDataSource _fcmDataSource;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  final _onNotificationOpenedController = StreamController<PushNotification>.broadcast();
  final _onForegroundNotificationController = StreamController<PushNotification>.broadcast();

  NotificationRepositoryImpl(this._fcmDataSource);

  @override
  Future<void> initialize() async {
    // 1. Setup Local Notifications for Foreground
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle local notification tap
        final notification = PushNotification(
          title: 'Local Notification',
          body: details.payload,
        );
        _onNotificationOpenedController.add(notification);
      },
    );

    // 2. Handle Initial Message (App opened from terminated state)
    final initialMessage = await _fcmDataSource.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationOpenedController.add(_mapRemoteMessage(initialMessage));
    }

    // 3. Listen for Foreground Messages
    _fcmDataSource.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      _onForegroundNotificationController.add(_mapRemoteMessage(message));
    });

    // 4. Listen for App Open from Background
    _fcmDataSource.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationOpenedController.add(_mapRemoteMessage(message));
    });
  }

  @override
  Future<String?> getToken() => _fcmDataSource.getToken();

  @override
  Future<void> requestPermission() => _fcmDataSource.requestPermission();

  @override
  Stream<PushNotification> get onNotificationOpened => _onNotificationOpenedController.stream;

  @override
  Stream<PushNotification> get onForegroundNotification => _onForegroundNotificationController.stream;

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  PushNotification _mapRemoteMessage(RemoteMessage message) {
    return PushNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
