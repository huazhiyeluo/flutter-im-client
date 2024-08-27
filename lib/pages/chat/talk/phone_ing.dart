import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:qim/utils/date.dart';
import 'package:qim/widget/custom_button.dart';

class PhoneIng extends StatefulWidget {
  final webrtc.RTCVideoRenderer remoteRenderer;
  final webrtc.RTCVideoRenderer localRenderer;
  final Function(int num) onPhoneQuit;
  final Function switchCamera;
  final Function turnCamera;

  const PhoneIng({
    super.key,
    required this.remoteRenderer,
    required this.localRenderer,
    required this.onPhoneQuit,
    required this.switchCamera,
    required this.turnCamera,
  });

  @override
  State<PhoneIng> createState() => _PhoneIngState();
}

class _PhoneIngState extends State<PhoneIng> {
  Timer? _chatTimer;

  bool numted = true;
  bool showbig = true;
  int second = 0;

  @override
  void initState() {
    startSecond();
    super.initState();
  }

  @override
  void dispose() {
    _chatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Positioned.fill(
                child: showbig ? showRemoteRtc() : showLocalRtc(),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 150,
                  height: 200,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showbig = !showbig;
                      });
                    },
                    child: showbig ? showLocalRtc() : showRemoteRtc(),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 50),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(128, 231, 224, 224), // 背景色
                            borderRadius: BorderRadius.circular(100), // 圆角
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch),
                            color: Colors.white,
                            onPressed: () {
                              widget.switchCamera();
                            },
                            iconSize: 50.0,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "翻转",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(128, 231, 224, 224), // 背景色
                            borderRadius: BorderRadius.circular(100), // 圆角
                          ),
                          child: IconButton(
                            icon: Icon(numted ? Icons.videocam : Icons.videocam_off),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                numted = !numted;
                              });
                              widget.turnCamera(numted);
                            },
                            iconSize: 50.0,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          numted ? "摄像头已开" : "摄像头已关",
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          widget.onPhoneQuit(second);
                        },
                        text: "挂断",
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                child: Text(
                  formatSecondsToHMS(second),
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget showRemoteRtc() {
    return widget.remoteRenderer.srcObject != null
        ? webrtc.RTCVideoView(
            widget.remoteRenderer,
            mirror: true,
            objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        : const Text('Waiting for remote video...');
  }

  Widget showLocalRtc() {
    return widget.localRenderer.srcObject != null
        ? webrtc.RTCVideoView(
            widget.localRenderer,
            mirror: true,
            objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        : const Text('Waiting for local video...');
  }

  void startSecond() {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        second++;
      });
    });
  }
}
