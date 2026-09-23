import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripTile extends StatelessWidget {
  const TripTile({
    super.key,
    required this.trip,
    required this.onToggle,
    this.onDelete,
  });

  final Trip trip;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RoutePoint(
                      icon: Icons.trip_origin,
                      color: Colors.grey.shade500,
                      label: trip.fromName,
                    ),
                  ),
                  Switch(value: trip.isActive, onChanged: onToggle),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Container(width: 2, height: 16, color: Colors.grey.shade300),
              ),
              _RoutePoint(
                icon: Icons.location_on_rounded,
                color: theme.colorScheme.primary,
                label: trip.toName,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.radar_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Alert within ${trip.radiusMeters.round()} m of destination',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
        ),
      ],
    );
  }
}
