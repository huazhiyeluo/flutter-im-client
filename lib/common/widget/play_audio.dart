import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:qim/common/widget/play_audio_manager.dart';

class PlayAudio extends StatefulWidget {
  final AudioManager audioManager;

  const PlayAudio(this.audioManager, {super.key});

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(widget.audioManager.playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (widget.audioManager.playerState == PlayerState.playing) {
                  widget.audioManager.pause();
                } else {
                  widget.audioManager.play();
                }
                setState(() {});
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    onChanged: (value) {
                      widget.audioManager.seek(value);
                      setState(() {});
                    },
                    value: (widget.audioManager.position != null && widget.audioManager.duration != null && widget.audioManager.position!.inMilliseconds > 0 && widget.audioManager.position!.inMilliseconds < widget.audioManager.duration!.inMilliseconds)
                        ? widget.audioManager.position!.inMilliseconds / widget.audioManager.duration!.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            )
          ],
        ),
        Text(
          widget.audioManager.position != null
              ? '${widget.audioManager.position!.toString().split('.').first} / ${widget.audioManager.duration!.toString().split('.').first}'
              : widget.audioManager.duration != null
                  ? widget.audioManager.duration!.toString().split('.').first
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}
