import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scan_mitra/models/event.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _enabled = true;

  Future<void> init() async {
    if (kIsWeb) {
      _enabled = false;
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);
    await _requestPermissions();
    await _configureTimezone();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  }

  Future<int> scheduleAutomaticReminders(List<Event> events) async {
    if (!_enabled) {
      return 0;
    }

    try {
      try {
        await _plugin.cancelAllPendingNotifications();
      } catch (_) {
        await _plugin.cancelAll();
      }

      var scheduledCount = 0;
      for (final event in events) {
        if (await _scheduleReminder(event: event, minutesBefore: 30)) {
          scheduledCount++;
        }
        if (await _scheduleReminder(event: event, minutesBefore: 15)) {
          scheduledCount++;
        }
      }

      return scheduledCount;
    } catch (_) {
      // Unit/widget tests can run without a notification platform implementation.
      return 0;
    }
  }

  Future<bool> _scheduleReminder({
    required Event event,
    required int minutesBefore,
  }) async {
    final reminderTime = event.startTime.subtract(Duration(minutes: minutesBefore));
    if (reminderTime.isBefore(DateTime.now())) {
      return false;
    }

    final notificationId = '${event.id}-$minutesBefore'.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Automatic reminders for upcoming itinerary events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Upcoming: ${event.title}',
      body: '${event.venue} at ${_time(event.startTime)}',
      scheduledDate: tz.TZDateTime.from(reminderTime.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: event.id,
    );

    return true;
  }

  Future<bool> scheduleQuickTest() async {
    if (!_enabled) {
      return false;
    }

    await _requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Automatic reminders for upcoming itinerary events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await Future<void>.delayed(const Duration(seconds: 5));
    await _plugin.show(
      id: 999999,
      title: 'ScanMitra Test',
      body: 'This is a 5-second test notification.',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: 'test',
    );

    return true;
  }

  String _time(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}
