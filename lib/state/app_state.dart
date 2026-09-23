import 'package:flutter/foundation.dart';
import '../models/clock_alarm.dart';
import '../models/trip.dart';
import '../services/geofence_monitor.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<ClockAlarm> _alarms = [];
  List<Trip> _trips = [];

  List<ClockAlarm> get alarms => List.unmodifiable(_alarms);
  List<Trip> get trips => List.unmodifiable(_trips);

  Future<void> load() async {
    await NotificationService.instance.init();
    _alarms = await _storage.loadAlarms();
    _trips = await _storage.loadTrips();
    for (final alarm in _alarms) {
      await NotificationService.instance.scheduleAlarm(alarm);
    }
    await GeofenceMonitor.instance.updateTrips(_trips);
    notifyListeners();
  }

  Future<void> addAlarm(ClockAlarm alarm) async {
    _alarms.add(alarm);
    await NotificationService.instance.scheduleAlarm(alarm);
    await _storage.saveAlarms(_alarms);
    notifyListeners();
  }

  Future<void> updateAlarm(ClockAlarm alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index == -1) return;
    _alarms[index] = alarm;
    await NotificationService.instance.scheduleAlarm(alarm);
    await _storage.saveAlarms(_alarms);
    notifyListeners();
  }

  Future<void> toggleAlarm(String id, bool value) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    alarm.isActive = value;
    await NotificationService.instance.scheduleAlarm(alarm);
    await _storage.saveAlarms(_alarms);
    notifyListeners();
  }

  Future<void> removeAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    await NotificationService.instance.cancelAlarm(id);
    await _storage.saveAlarms(_alarms);
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    await _storage.saveTrips(_trips);
    await GeofenceMonitor.instance.updateTrips(_trips);
    notifyListeners();
  }

  Future<void> toggleTrip(String id, bool value) async {
    final trip = _trips.firstWhere((t) => t.id == id);
    trip.isActive = value;
    await _storage.saveTrips(_trips);
    await GeofenceMonitor.instance.updateTrips(_trips);
    notifyListeners();
  }

  Future<void> removeTrip(String id) async {
    _trips.removeWhere((t) => t.id == id);
    await _storage.saveTrips(_trips);
    await GeofenceMonitor.instance.updateTrips(_trips);
    notifyListeners();
  }
}
