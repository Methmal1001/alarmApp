import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/alarm_sound.dart';
import '../models/trip.dart';
import 'location_service.dart';
import 'notification_service.dart';

class GeofenceMonitor {
  GeofenceMonitor._();
  static final GeofenceMonitor instance = GeofenceMonitor._();

  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _sub;
  final Map<String, bool> _insideZone = {};
  List<Trip> _trips = [];
  AlarmSound _sound = AlarmSound.classic;

  void updateSound(AlarmSound sound) {
    _sound = sound;
  }

  Future<void> updateTrips(List<Trip> trips) async {
    _trips = trips;
    final anyActive = trips.any((t) => t.isActive);

    if (!anyActive) {
      await _stop();
      return;
    }

    final granted = await _locationService.ensurePermission(background: true);
    if (!granted) return;

    _sub ??= _locationService.watchPosition().listen(_onPosition);
  }

  void _onPosition(Position position) {
    for (final trip in _trips) {
      if (!trip.isActive) {
        _insideZone[trip.id] = false;
        continue;
      }
      final distance = _locationService.distanceMeters(
        lat1: position.latitude,
        lng1: position.longitude,
        lat2: trip.toLat,
        lng2: trip.toLng,
      );
      final isInside = distance <= trip.radiusMeters;
      final wasInside = _insideZone[trip.id] ?? false;

      if (isInside && !wasInside) {
        NotificationService.instance.showGeofenceAlert(trip, _sound);
      }
      _insideZone[trip.id] = isInside;
    }
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;
    _insideZone.clear();
  }
}
