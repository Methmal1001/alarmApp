import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmSoundPlayer {
  AlarmSoundPlayer._();
  static final AlarmSoundPlayer instance = AlarmSoundPlayer._();

  final AudioPlayer _player = AudioPlayer();
  bool _ringing = false;

  bool get isRinging => _ringing;

  Future<void> start({String assetPath = 'sounds/alarm.wav'}) async {
    if (_ringing) return;
    _ringing = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath), volume: 1.0);
    _vibrateLoop();
  }

  Future<void> _vibrateLoop() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;
    while (_ringing) {
      Vibration.vibrate(pattern: const [0, 400, 200, 400]);
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  Future<void> stop() async {
    _ringing = false;
    await _player.stop();
    Vibration.cancel();
  }
}
