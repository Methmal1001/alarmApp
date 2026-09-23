enum AlarmSound {
  classic('alarm', 'Classic Beep', 'sounds/alarm.wav'),
  chime('alarm_chime', 'Gentle Chime', 'sounds/alarm_chime.wav'),
  pulse('alarm_pulse', 'Urgent Pulse', 'sounds/alarm_pulse.wav');

  const AlarmSound(this.id, this.displayName, this.assetPath);

  /// Matches the Android raw resource name (res/raw/`id`.wav) used for
  /// native notification sounds, and doubles as the persisted preference key.
  final String id;
  final String displayName;
  final String assetPath;

  static AlarmSound fromId(String? id) => AlarmSound.values.firstWhere(
        (s) => s.id == id,
        orElse: () => AlarmSound.classic,
      );
}
