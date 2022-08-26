import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  void release() async {
    await _player.stop();
    await _player.release();
  }
}
