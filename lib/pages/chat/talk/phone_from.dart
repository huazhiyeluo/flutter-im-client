import 'package:flutter/material.dart';
import 'package:qim/widget/custom_button.dart';

class PhoneFrom extends StatefulWidget {
  final Map talkCommonObj;
  final Function onPhoneQuit;
  final Function onPhoneAccept;

  const PhoneFrom({super.key, required this.talkCommonObj, required this.onPhoneQuit, required this.onPhoneAccept});

  @override
  State<PhoneFrom> createState() => _PhoneFromState();
}

class _PhoneFromState extends State<PhoneFrom> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(
              widget.talkCommonObj['icon'],
              scale: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.talkCommonObj['name'],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "邀请您视频通话...",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onPhoneQuit();
                  },
                  text: "挂断",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onPhoneAccept();
                  },
                  text: "接听",
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
