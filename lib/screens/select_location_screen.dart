import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/geocoding_service.dart';
import '../state/app_state.dart';
import 'location_picker_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  PlaceResult? _from;
  PlaceResult? _to;
  double _radius = 300;

  Future<void> _pickFrom() async {
    final result = await Navigator.of(context).push<PlaceResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen(title: 'From location')),
    );
    if (result != null) setState(() => _from = result);
  }

  Future<void> _pickTo() async {
    final result = await Navigator.of(context).push<PlaceResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen(title: 'To location')),
    );
    if (result != null) setState(() => _to = result);
  }

  void _save() {
    if (_from == null || _to == null) return;
    final trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fromName: _from!.name,
      fromLat: _from!.lat,
      fromLng: _from!.lng,
      toName: _to!.name,
      toLat: _to!.lat,
      toLng: _to!.lng,
      radiusMeters: _radius,
    );
    context.read<AppState>().addTrip(trip);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _from != null && _to != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Set Location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LocationField(
            label: 'From',
            icon: Icons.trip_origin,
            iconColor: Colors.grey.shade500,
            value: _from?.name,
            onTap: _pickFrom,
          ),
          const SizedBox(height: 14),
          _LocationField(
            label: 'To',
            icon: Icons.location_on_rounded,
            iconColor: theme.colorScheme.primary,
            value: _to?.name,
            onTap: _pickTo,
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.radar_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text('Alert radius'),
                      const Spacer(),
                      Text('${_radius.round()} m', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 100,
                    max: 1000,
                    divisions: 18,
                    label: '${_radius.round()} m',
                    onChanged: (value) => setState(() => _radius = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'LocateMe will alert you with sound and vibration once you get within '
              '${_radius.round()} m of your destination.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: canSave ? _save : null,
            child: const Text('Save Location Alarm'),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: iconColor),
        title: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
        subtitle: Text(
          value ?? 'Tap to select',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: value == null ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
