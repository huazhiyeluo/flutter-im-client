import 'package:flutter/material.dart';
import 'package:qim/common/widget/custom_button.dart';

class PhoneTo extends StatefulWidget {
  final Map talkCommonObj;
  final Function onPhoneCancel;

  const PhoneTo({super.key, required this.talkCommonObj, required this.onPhoneCancel});

  @override
  State<PhoneTo> createState() => _PhoneToState();
}

class _PhoneToState extends State<PhoneTo> {
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
            "正在呼叫...",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onPhoneCancel();
                  },
                  text: "取消",
                ),
              ),
              const SizedBox(width: 30),
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
