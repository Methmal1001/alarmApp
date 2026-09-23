import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../app_navigator.dart';
import '../models/alarm_sound.dart';
import '../models/clock_alarm.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import 'alarm_sound_player.dart';
import '../screens/full_screen_alarm_screen.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static String _channelId(AlarmSound sound) => 'alarm_channel_${sound.id}';

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to UTC if the platform timezone name can't be resolved.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleTap,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    for (final sound in AlarmSound.values) {
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId(sound),
          'Alarms (${sound.displayName})',
          description: 'LocateMe alarms using the ${sound.displayName} tone',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound.id),
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void _handleTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final type = data['type'] as String?;
    final sound = AlarmSound.fromId(data['sound'] as String?);
    if (type == 'alarm') {
      final id = data['id'] as String?;
      final appState = rootNavigatorKey.currentContext?.read<AppState>();
      ClockAlarm? alarm;
      if (id != null && appState != null) {
        try {
          alarm = appState.alarms.firstWhere((a) => a.id == id);
        } catch (_) {
          alarm = null;
        }
      }
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => FullScreenAlarmScreen(
            type: AlarmAlertType.timeAlarm,
            title: (data['label'] as String?)?.isNotEmpty == true
                ? data['label'] as String
                : 'Alarm',
            subtitle: 'Time to wake up',
            soundAssetPath: sound.assetPath,
            onSnooze: alarm == null ? null : () => snoozeAlarm(alarm!, sound),
          ),
        ),
      );
    } else if (type == 'trip') {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => FullScreenAlarmScreen(
            type: AlarmAlertType.geofence,
            title: 'You have arrived!',
            subtitle: 'You are near ${data['toName']}',
            soundAssetPath: sound.assetPath,
          ),
        ),
      );
    }
  }

  int _baseId(String id) => id.hashCode & 0x7fffffff;

  AndroidNotificationDetails _alarmDetails(AlarmSound sound) => AndroidNotificationDetails(
        _channelId(sound),
        'Alarms (${sound.displayName})',
        channelDescription: 'LocateMe alarms using the ${sound.displayName} tone',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(sound.id),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        ongoing: false,
        autoCancel: true,
      );

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (weekday == null) {
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else {
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    return scheduled;
  }

  Future<void> scheduleAlarm(ClockAlarm alarm, AlarmSound sound) async {
    await cancelAlarm(alarm.id);
    if (!alarm.isActive) return;

    final payload = jsonEncode({
      'type': 'alarm',
      'id': alarm.id,
      'label': alarm.label,
      'sound': sound.id,
    });
    final details = NotificationDetails(android: _alarmDetails(sound));

    if (alarm.repeatDays.isEmpty) {
      final when = _nextInstanceOfTime(alarm.hour, alarm.minute);
      await _plugin.zonedSchedule(
        id: _baseId(alarm.id),
        title: alarm.label.isEmpty ? 'Alarm' : alarm.label,
        body: 'Time to wake up',
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } else {
      for (final weekday in alarm.repeatDays) {
        final when = _nextInstanceOfTime(alarm.hour, alarm.minute, weekday: weekday);
        await _plugin.zonedSchedule(
          id: _baseId(alarm.id) + 100 + weekday,
          title: alarm.label.isEmpty ? 'Alarm' : alarm.label,
          body: 'Time to wake up',
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
      }
    }
  }

  Future<void> cancelAlarm(String id) async {
    await _plugin.cancel(id: _baseId(id));
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id: _baseId(id) + 100 + weekday);
    }
  }

  Future<void> snoozeAlarm(ClockAlarm alarm, AlarmSound sound, {int minutes = 5}) async {
    final when = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
    final payload = jsonEncode({
      'type': 'alarm',
      'id': alarm.id,
      'label': alarm.label,
      'sound': sound.id,
    });
    await _plugin.zonedSchedule(
      id: _baseId(alarm.id) + 900,
      title: alarm.label.isEmpty ? 'Alarm' : alarm.label,
      body: 'Snoozed alarm',
      scheduledDate: when,
      notificationDetails: NotificationDetails(android: _alarmDetails(sound)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> showGeofenceAlert(Trip trip, AlarmSound sound) async {
    final payload = jsonEncode({
      'type': 'trip',
      'id': trip.id,
      'toName': trip.toName,
      'sound': sound.id,
    });
    await _plugin.show(
      id: _baseId(trip.id),
      title: 'You have arrived!',
      body: 'You are near ${trip.toName}',
      notificationDetails: NotificationDetails(android: _alarmDetails(sound)),
      payload: payload,
    );

    // If the app is already visible, pop the full-screen alert immediately too —
    // the notification's fullScreenIntent mainly covers the locked/background case.
    if (!AlarmSoundPlayer.instance.isRinging) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => FullScreenAlarmScreen(
            type: AlarmAlertType.geofence,
            title: 'You have arrived!',
            subtitle: 'You are near ${trip.toName}',
            soundAssetPath: sound.assetPath,
          ),
        ),
      );
    }
  }
}
