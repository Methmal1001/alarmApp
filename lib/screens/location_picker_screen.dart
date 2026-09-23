import 'dart:async';
import 'package:flutter/material.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, required this.title});

  final String title;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _geocoding = GeocodingService();
  final _locationService = LocationService();
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PlaceResult> _results = [];
  bool _loading = false;
  bool _loadingCurrent = false;
  String? _error;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String value) async {
    if (value.trim().length < 3) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await _geocoding.search(value);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = results;
      _error = results.isEmpty ? 'No matches found. Try a more specific address.' : null;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingCurrent = true);
    final position = await _locationService.currentPosition();
    if (!mounted) return;
    setState(() => _loadingCurrent = false);
    if (position == null) {
      setState(() => _error = 'Location permission denied or GPS unavailable.');
      return;
    }
    final name = await _geocoding.nameForCoordinates(position.latitude, position.longitude);
    if (!mounted) return;
    Navigator.of(context).pop(PlaceResult(name: name, lat: position.latitude, lng: position.longitude));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Search for a place or address',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          ListTile(
            leading: _loadingCurrent
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.my_location_rounded, color: theme.colorScheme.primary),
            title: const Text('Use current location'),
            onTap: _loadingCurrent ? null : _useCurrentLocation,
          ),
          const Divider(height: 1),
          if (_loading) const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!, style: TextStyle(color: Colors.grey.shade500)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final place = _results[index];
                return ListTile(
                  leading: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                  title: Text(place.name),
                  subtitle: Text('${place.lat.toStringAsFixed(5)}, ${place.lng.toStringAsFixed(5)}'),
                  onTap: () => Navigator.of(context).pop(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
