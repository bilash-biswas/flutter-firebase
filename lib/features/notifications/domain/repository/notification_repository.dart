import 'package:flutter_firebase/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<void> initialize();
  Future<String?> getToken();
  Stream<PushNotification> get onNotificationOpened;
  Stream<PushNotification> get onForegroundNotification;
  Future<void> requestPermission();
}
