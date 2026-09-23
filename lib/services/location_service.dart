import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermission({bool background = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    if (background && permission != LocationPermission.always) {
      // On Android this re-requests and the OS shows the "Allow all the time" option.
      permission = await Geolocator.requestPermission();
    }

    return true;
  }

  Future<Position?> currentPosition() async {
    final granted = await ensurePermission();
    if (!granted) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double distanceMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Stream<Position> watchPosition({bool foregroundService = true}) {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
      intervalDuration: const Duration(seconds: 10),
      foregroundNotificationConfig: foregroundService
          ? const ForegroundNotificationConfig(
              notificationTitle: 'LocateMe is watching your destination',
              notificationText: 'You will be alerted when you arrive',
              enableWakeLock: true,
              notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
            )
          : null,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
