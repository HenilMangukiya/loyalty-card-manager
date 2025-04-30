import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> scheduleCardExpirationNotification({
    required String cardName,
    required DateTime expirationDate,
    required String cardId,
  }) async {
    if (!_isInitialized) await initialize();

    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    // Only schedule notification if card is expiring within 30 days
    if (daysUntilExpiration <= 30 && daysUntilExpiration > 0) {
      final notificationTime = expirationDate.subtract(const Duration(days: 1));

      // Convert string ID to a unique integer for notification ID
      final notificationId = cardId.hashCode.abs();

      await _notifications.zonedSchedule(
        notificationId,
        'Card Expiration Reminder',
        'Your $cardName card will expire tomorrow!',
        tz.TZDateTime.from(notificationTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'card_expiration_channel',
            'Card Expiration Notifications',
            channelDescription: 'Notifications for expiring loyalty cards',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      notifyListeners();
    }
  }

  Future<void> cancelNotification(String cardId) async {
    if (!_isInitialized) await initialize();
    // Convert string ID to the same integer used for scheduling
    final notificationId = cardId.hashCode.abs();
    await _notifications.cancel(notificationId);
    notifyListeners();
  }
}
