import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudio extends StatefulWidget {
  final String audioUrl;

  const PlayAudio(
    this.audioUrl, {
    super.key,
  });

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _playerState = _audioPlayer.state;
    _audioPlayer.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    _audioPlayer.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );

    _initStreams();
    _initPlayer();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initStreams() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  void _initPlayer() async {
    await _audioPlayer.setSource(UrlSource(widget.audioUrl));
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
              onPressed: _playerState == PlayerState.playing ? _pause : _play,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    onChanged: (value) {
                      final duration = _duration;
                      if (duration == null) {
                        return;
                      }
                      final position = value * duration.inMilliseconds;
                      _audioPlayer.seek(Duration(milliseconds: position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position!.inMilliseconds > 0 &&
                            _position!.inMilliseconds < _duration!.inMilliseconds)
                        ? _position!.inMilliseconds / _duration!.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            )
          ],
        ),
        Text(
          _position != null
              ? '${_position!.toString().split('.').first} / ${_duration!.toString().split('.').first}'
              : _duration != null
                  ? _duration!.toString().split('.').first
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Future<void> _play() async {
    await _audioPlayer.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
