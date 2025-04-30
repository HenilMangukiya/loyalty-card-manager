import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);
  }

  Future<void> scheduleExpiryNotification(
    String cardName,
    DateTime expiryDate,
  ) async {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.inDays <= 30 && difference.inDays >= 0) {
      await _localNotifications.zonedSchedule(
        expiryDate.millisecondsSinceEpoch ~/ 1000,
        'Card Expiry Alert',
        'Your $cardName card will expire in ${difference.inDays} days',
        tz.TZDateTime.from(expiryDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'card_expiry',
            'Card Expiry Notifications',
            channelDescription: 'Notifications for card expiry alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
