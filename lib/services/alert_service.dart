import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class AlertService {
  final _player = AudioPlayer();

  Future<void> startAlert() async {
    if (!kIsWeb && await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 500, 500], repeat: 1);
    }

    await _player.play(AssetSource('alarm.mp3'), volume: 1.0);
  }

  Future<void> stopAlert() async {
    if (!kIsWeb) {
      Vibration.cancel();
    }
    await _player.stop();
  }
}
