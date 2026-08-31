import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';

/// Local reminder notifications. Everything is scheduled on-device in the
/// device's timezone — a reminder means "9 AM where the user lives". No
/// server push is involved; record timestamps remain server-side UTC.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _permissionAsked = false;

  /// The local hour reminders fire at.
  static const _fireHour = 9;

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to the package default (UTC) if the platform lookup fails.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          // Ask at first schedule instead of app launch.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  static Future<void> _ensurePermission() async {
    if (_permissionAsked) return;
    _permissionAsked = true;
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// What is currently scheduled — used by integration tests to verify the
  /// reminder list and the notification queue stay in sync.
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  /// Mirror the pending reminder list into scheduled notifications.
  /// Called whenever reminders change; cancel-all-then-reschedule keeps the
  /// two in sync without tracking per-reminder notification ids.
  static Future<void> sync(List<Reminder> reminders) async {
    if (!_ready) return;
    if (reminders.isNotEmpty) await _ensurePermission();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    var id = 0;
    for (final r in reminders) {
      var fireAt = tz.TZDateTime(tz.local, r.due.year, r.due.month, r.due.day, _fireHour);
      // Due today but 9 AM already passed → nudge shortly instead of never.
      if (fireAt.isBefore(now)) {
        if (r.daysLeft < 0) continue; // overdue: shown in-app, don't re-notify
        fireAt = now.add(const Duration(minutes: 2));
      }
      await _plugin.zonedSchedule(
        id: id++,
        title: r.title,
        body: r.detail.isEmpty ? 'Maison reminder' : r.detail,
        scheduledDate: fireAt,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'reminders',
            'Maintenance reminders',
            channelDescription: 'Due dates for home maintenance and warranties',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
