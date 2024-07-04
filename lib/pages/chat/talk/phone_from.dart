import 'package:flutter/material.dart';
import 'package:qim/widget/custom_button.dart';

class PhoneFrom extends StatefulWidget {
  final Map talkObj;
  final Function onPhoneFromFalse;
  final Function onPhoneFromTrue;

  const PhoneFrom({super.key, required this.talkObj, required this.onPhoneFromFalse, required this.onPhoneFromTrue});

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
              widget.talkObj['icon'],
              scale: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.talkObj['name'],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "正在呼叫...",
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
                    widget.onPhoneFromFalse();
                  },
                  text: "挂断",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onPhoneFromTrue();
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