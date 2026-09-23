import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/geocoding_service.dart';
import '../state/app_state.dart';
import 'location_picker_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key, this.existing});

  final Trip? existing;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  PlaceResult? _from;
  PlaceResult? _to;
  double _radius = 300;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _from = PlaceResult(name: existing.fromName, lat: existing.fromLat, lng: existing.fromLng);
      _to = PlaceResult(name: existing.toName, lat: existing.toLat, lng: existing.toLng);
      _radius = existing.radiusMeters;
    }
  }

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
    final existing = widget.existing;
    final trip = Trip(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      fromName: _from!.name,
      fromLat: _from!.lat,
      fromLng: _from!.lng,
      toName: _to!.name,
      toLat: _to!.lat,
      toLng: _to!.lng,
      radiusMeters: _radius,
      isActive: existing?.isActive ?? true,
    );
    if (existing == null) {
      context.read<AppState>().addTrip(trip);
    } else {
      context.read<AppState>().updateTrip(trip);
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<AppState>().removeTrip(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _from != null && _to != null;
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Location Alarm' : 'Set Location'),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
            child: Text(isEditing ? 'Update Location Alarm' : 'Save Location Alarm'),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
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
      ),
    );
  }
}
