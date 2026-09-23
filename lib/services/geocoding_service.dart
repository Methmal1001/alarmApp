import 'package:geocoding/geocoding.dart';

class PlaceResult {
  PlaceResult({required this.name, required this.lat, required this.lng});
  final String name;
  final double lat;
  final double lng;
}

class GeocodingService {
  final Geocoding _geocoding = Geocoding();

  Future<List<PlaceResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final locations = await _geocoding.locationFromAddress(query);
      final results = <PlaceResult>[];
      for (final loc in locations.take(6)) {
        String label = query;
        try {
          final placemarks = await _geocoding.placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            label = [p.name, p.locality, p.administrativeArea]
                .where((e) => e != null && e.isNotEmpty)
                .join(', ');
            if (label.isEmpty) label = query;
          }
        } catch (_) {
          // Fall back to the raw query as the label if reverse geocoding fails.
        }
        results.add(PlaceResult(name: label, lat: loc.latitude, lng: loc.longitude));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<String> nameForCoordinates(double lat, double lng) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Current location';
      final p = placemarks.first;
      final label = [p.name, p.locality, p.administrativeArea]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
      return label.isEmpty ? 'Current location' : label;
    } catch (_) {
      return 'Current location';
    }
  }
}
