import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    // 1. Check if Firebase is initialized safely
    try {
      if (Firebase.apps.isEmpty) {
        // In a real project, this requires google-services.json
        // We catch its absence to avoid crashing the whole app
        print('FCM: Firebase core not yet configured. Skipping initialization.');
        return;
      }
    } catch (e) {
      print('FCM: Initialization error (likely missing config): $e');
      return;
    }

    // 2. Request permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Local notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 4. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 5. Handle background clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to sub-page if needed
    });
  }

  Future<void> updateFcmToken() async {
    try {
      if (Firebase.apps.isEmpty) return;
      
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _ref.read(apiClientProvider).patch(
          '/users/me/fcm-token',
          data: {'fcmToken': token},
        );
      }
    } catch (e) {
      print('FCM: Error updating token: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;
    
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
