import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_sound.dart';
import '../models/clock_alarm.dart';
import '../models/trip.dart';

class StorageService {
  static const _alarmsKey = 'clock_alarms';
  static const _tripsKey = 'trips';
  static const _soundKey = 'alarm_sound';

  Future<List<ClockAlarm>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alarmsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ClockAlarm.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAlarms(List<ClockAlarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
  }

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tripsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tripsKey, jsonEncode(trips.map((t) => t.toJson()).toList()));
  }

  Future<AlarmSound> loadAlarmSound() async {
    final prefs = await SharedPreferences.getInstance();
    return AlarmSound.fromId(prefs.getString(_soundKey));
  }

  Future<void> saveAlarmSound(AlarmSound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, sound.id);
  }
}
