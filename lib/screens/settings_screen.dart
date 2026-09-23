import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_sound.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  AlarmSound? _previewing;

  Future<void> _preview(AlarmSound sound) async {
    if (_previewing == sound) {
      await _previewPlayer.stop();
      setState(() => _previewing = null);
      return;
    }
    setState(() => _previewing = sound);
    await _previewPlayer.stop();
    await _previewPlayer.setReleaseMode(ReleaseMode.release);
    await _previewPlayer.play(AssetSource(sound.assetPath), volume: 1.0);
    _previewPlayer.onPlayerComplete.first.then((_) {
      if (mounted && _previewing == sound) setState(() => _previewing = null);
    });
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text('Alarm sound', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14, left: 4),
            child: Text(
              'Used for both clock alarms and location arrival alerts.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
            ),
          ),
          RadioGroup<AlarmSound>(
            groupValue: state.selectedSound,
            onChanged: (value) {
              if (value != null) context.read<AppState>().setAlarmSound(value);
            },
            child: Column(
              children: AlarmSound.values.map((sound) {
                final selected = state.selectedSound == sound;
                final previewing = _previewing == sound;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        selected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? theme.colorScheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.read<AppState>().setAlarmSound(sound),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Radio<AlarmSound>(value: sound),
                            Expanded(
                              child: Text(
                                sound.displayName,
                                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                previewing ? Icons.stop_circle_rounded : Icons.play_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () => _preview(sound),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Location alarms rely on GPS and background location access. '
                    'Battery savers and some device manufacturers may limit background '
                    'tracking — keep the app open while traveling for the most reliable alerts.',
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
