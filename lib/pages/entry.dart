import 'package:flutter/material.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/utils/cache.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EntryPage(),
    );
  }
}

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  String _initialRoute = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    CacheHelper.saveBoolData(Keys.entryPage, true);
    String initialRouteData = initialRoute();
    setState(() {
      _initialRoute = initialRouteData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const SizedBox(height: 135),
        Image.asset("lib/assets/images/welcome.jpg", width: 262, height: 271),
        const SizedBox(height: 42),
        Container(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: const Text(
            'Connect easily with\n your family and friends\n over countries',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: Container()),
        const Text(
          "Terms & Privacy Policy",
          style: TextStyle(),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    _initialRoute,
                    (route) => false,
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue,
                  ), // 按钮背景色
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ), // 文字颜色
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  ), // 内边距
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(fontSize: 18),
                  ), // 文字样式
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ), // 圆角边框
                ),
                child: const Text("Start Messaging"),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 45),
      ],
    ));
  }
}
