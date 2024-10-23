import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  late AudioPlayer _audioPlayer;
  PlayerState? playerState;
  Duration? duration;
  Duration? position;

  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerStateChangeSubscription;

  AudioManager() {
    _audioPlayer = AudioPlayer();
    _initStreams();
  }

  void disposeA() {
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
  }

  void _initStreams() {
    durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      this.duration = duration;
    });

    positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
      position = p;
    });

    playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      playerState = PlayerState.stopped;
      position = Duration.zero;
    });

    playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      playerState = state;
    });
  }

  Future<void> setAudioSource(String audioUrl) async {
    await _audioPlayer.setSource(UrlSource(audioUrl));
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> play() async {
    await _audioPlayer.resume();
    playerState = PlayerState.playing;
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    playerState = PlayerState.paused;
  }

  void seek(double value) {
    if (duration != null) {
      final positionInMillis = value * duration!.inMilliseconds;
      _audioPlayer.seek(Duration(milliseconds: positionInMillis.round()));
    }
  }
}
