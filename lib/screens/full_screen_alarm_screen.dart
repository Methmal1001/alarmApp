import 'package:flutter/material.dart';
import '../services/alarm_sound_player.dart';

enum AlarmAlertType { timeAlarm, geofence }

class FullScreenAlarmScreen extends StatefulWidget {
  const FullScreenAlarmScreen({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.soundAssetPath = 'sounds/alarm.wav',
    this.onSnooze,
  });

  final AlarmAlertType type;
  final String title;
  final String subtitle;
  final String soundAssetPath;
  final VoidCallback? onSnooze;

  @override
  State<FullScreenAlarmScreen> createState() => _FullScreenAlarmScreenState();
}

class _FullScreenAlarmScreenState extends State<FullScreenAlarmScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    AlarmSoundPlayer.instance.start(assetPath: widget.soundAssetPath);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _dismiss() {
    AlarmSoundPlayer.instance.stop();
    Navigator.of(context).maybePop();
  }

  void _snooze() {
    AlarmSoundPlayer.instance.stop();
    widget.onSnooze?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final isGeofence = widget.type == AlarmAlertType.geofence;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF12233A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.08).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      isGeofence ? Icons.location_on_rounded : Icons.alarm_rounded,
                      color: Colors.white,
                      size: 68,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (!isGeofence)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.white54),
                          ),
                          onPressed: _snooze,
                          child: const Text('Snooze 5 min', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    if (!isGeofence) const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF12233A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _dismiss,
                        child: const Text('Dismiss'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
