import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/clock_alarm_tile.dart';
import '../widgets/trip_tile.dart';
import 'select_location_screen.dart';
import 'set_alarm_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeAlarms = state.alarms.where((a) => a.isActive).length;
    final activeTrips = state.trips.where((t) => t.isActive).length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(activeAlarms: activeAlarms, activeTrips: activeTrips),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DashboardActionCard(
                          title: 'Set Alarm',
                          subtitle: 'Wake up on time',
                          icon: Icons.alarm_add_rounded,
                          color: const Color(0xFF3B6FE0),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SetAlarmScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DashboardActionCard(
                          title: 'Set Location',
                          subtitle: 'Alert on arrival',
                          icon: Icons.location_on_rounded,
                          color: const Color(0xFF2E7D6B),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Clock Alarms',
                    onAdd: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SetAlarmScreen()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (state.alarms.isEmpty)
                    const _EmptyHint(text: 'No alarms yet. Tap + to add one.')
                  else
                    ...state.alarms.map(
                      (alarm) => ClockAlarmTile(
                        alarm: alarm,
                        onToggle: (value) => context.read<AppState>().toggleAlarm(alarm.id, value),
                        onDelete: () => context.read<AppState>().removeAlarm(alarm.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SetAlarmScreen(existing: alarm)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _SectionHeader(
                    title: 'Location Alarms',
                    onAdd: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (state.trips.isEmpty)
                    const _EmptyHint(text: 'No location alarms yet. Tap + to add a route.')
                  else
                    ...state.trips.map(
                      (trip) => TripTile(
                        trip: trip,
                        onToggle: (value) => context.read<AppState>().toggleTrip(trip.id, value),
                        onDelete: () => context.read<AppState>().removeTrip(trip.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SelectLocationScreen(existing: trip)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeAlarms, required this.activeTrips});

  final int activeAlarms;
  final int activeTrips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12233A), Color(0xFF2E7D6B)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              const Text(
                'LocateMe',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Never miss a moment',
            style: TextStyle(color: Colors.white70, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.alarm_rounded,
                  value: '$activeAlarms',
                  label: 'active alarms',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  icon: Icons.pin_drop_rounded,
                  value: '$activeTrips',
                  label: 'location alerts',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}
