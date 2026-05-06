import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_firebase/features/notifications/data/datasources/fcm_datasource.dart';
import 'package:flutter_firebase/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:flutter_firebase/features/notifications/domain/repository/notification_repository.dart';

final fcmDataSourceProvider = Provider<FCMDataSource>((ref) => FCMDataSource());

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dataSource = ref.watch(fcmDataSourceProvider);
  return NotificationRepositoryImpl(dataSource);
});

// A provider to handle initialization and provide access to the notification stream
final notificationInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  await repository.initialize();
  await repository.requestPermission();
  
  // Optionally log the token
  final token = await repository.getToken();
  print('FCM Token: $token');
});
