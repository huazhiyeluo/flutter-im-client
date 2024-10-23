import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class PlayVideo extends StatefulWidget {
  final ChewieController chewieController;
  final double aspectRatio;

  const PlayVideo(
    this.chewieController, {
    this.aspectRatio = 16 / 9,
    super.key,
  });

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(
        controller: widget.chewieController,
      ),
    );
  }
}
