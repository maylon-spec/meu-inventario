import 'package:audioplayers/audioplayers.dart';

class ScanFeedback {
  ScanFeedback._();
  static final instance = ScanFeedback._();
  final AudioPlayer _player = AudioPlayer();

  Future<void> successBeep() async {
    await _player.play(AssetSource('audio/scan_beep.wav'));
  }
}
