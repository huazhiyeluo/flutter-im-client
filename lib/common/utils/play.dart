import 'package:audioplayers/audioplayers.dart';

class PlayerTips {
  late AudioPlayer? _audioPlayer;
  DateTime? _lastPlayTime;

  void _initializePlayer() {
    _audioPlayer = AudioPlayer();
  }

  PlayerTips() {
    _initializePlayer();
  }

  Future<void> playSound(String mp3) async {
    try {
      if (_audioPlayer == null) {
        _initializePlayer();
      }
      final currentTime = DateTime.now();
      if (_lastPlayTime == null || currentTime.difference(_lastPlayTime!).inSeconds >= 1) {
        _audioPlayer?.audioCache = AudioCache(prefix: '');
        await _audioPlayer?.play(AssetSource('lib/assets/voices/$mp3'), mode: PlayerMode.mediaPlayer);
        _lastPlayTime = currentTime;
      }
    } catch (e) {
      throw Exception('Failed to play sound: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer?.stop();
      _releaseResources();
    } catch (e) {
      throw Exception('Failed to stop sound: $e');
    }
  }

  void _releaseResources() {
    _audioPlayer?.dispose();
  }

  void dispose() {
    _releaseResources();
  }
}
