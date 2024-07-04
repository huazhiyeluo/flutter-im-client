import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:qim/widget/custom_button.dart';

class PhoneIng extends StatefulWidget {
  final webrtc.RTCVideoRenderer remoteRenderer;
  final webrtc.RTCVideoRenderer localRenderer;
  final Function onPhoneIng;

  const PhoneIng({super.key, required this.remoteRenderer, required this.localRenderer, required this.onPhoneIng});

  @override
  State<PhoneIng> createState() => _PhoneIngState();
}

class _PhoneIngState extends State<PhoneIng> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: widget.remoteRenderer.srcObject != null
                    ? webrtc.RTCVideoView(
                        widget.remoteRenderer,
                        mirror: true,
                        objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const Text('Waiting for remote video...'),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 150,
                  height: 200,
                  child: widget.localRenderer.srcObject != null
                      ? webrtc.RTCVideoView(
                          widget.localRenderer,
                          mirror: true,
                          objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Text('Waiting for local video...'),
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
                          widget.onPhoneIng();
                        },
                        text: "挂断",
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
