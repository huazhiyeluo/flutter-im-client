import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';

class TalkPhoneTo extends StatefulWidget {
  const TalkPhoneTo({super.key});

  @override
  State<TalkPhoneTo> createState() => _TalkPhoneToState();
}

class _TalkPhoneToState extends State<TalkPhoneTo> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(125, 0, 0, 125),
      body: TalkPhoneToPage(),
    );
  }
}

class TalkPhoneToPage extends StatefulWidget {
  const TalkPhoneToPage({super.key});

  @override
  State<TalkPhoneToPage> createState() => _TalkPhoneToPageState();
}

class _TalkPhoneToPageState extends State<TalkPhoneToPage> {
  final TalkobjController talkobjController = Get.find();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
    _fetchData();
    super.initState();
  }

  void _fetchData() async {}

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
              talkObj['icon'],
              scale: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            talkObj['name'],
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
                child: TextButton(
                  onPressed: () {
                    _quitPhone();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ), // 按钮背景色
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ), // 文字颜色
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ), // 内边距
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 18),
                    ), // 文字样式
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ), // 圆角边框
                  ),
                  child: const Text("挂断"),
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

  _quitPhone() {
    Map msg = {
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 1,
      'msgType': 4
    };
    Get.arguments['channel'].sendMessage(jsonEncode(msg));

    Map msgshow = {
      'content': {'data': "挂断电话"},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 13,
      'msgType': 1
    };
    Get.arguments['channel'].sendMessage(jsonEncode(msgshow));

    Navigator.pop(context);
  }
}
