import 'package:audioplayers/audioplayers.dart';

class AudioPlayerManager {
  late AudioPlayer _audioPlayer;

  AudioPlayerManager() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.audioCache = AudioCache(prefix: '');
  }

  Future<void> playSound(String mp3) async {
    try {
      await _audioPlayer.play(AssetSource('lib/assets/voices/$mp3'), mode: PlayerMode.mediaPlayer);
    } catch (e) {
      throw Exception('Failed to play sound: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _releaseResources();
    } catch (e) {
      throw Exception('Failed to stop sound: $e');
    }
  }

  void _releaseResources() {
    _audioPlayer.dispose();
  }

  void dispose() {
    _releaseResources();
  }
}
