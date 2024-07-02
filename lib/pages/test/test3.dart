import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qim/pages/test/test2.dart';

class Test3 extends StatefulWidget {
  const Test3({super.key});

  @override
  State<Test3> createState() => _Test3State();
}

class _Test3State extends State<Test3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DEMO"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (BuildContext context) {
              //       return const Test2("nihao");
              //     },
              //     settings: const RouteSettings(
              //       name: "test",
              //       arguments: {"name": "liao", "age": 33},
              //     ),
              //   ),
              // );

              Navigator.pushNamed(context, "/test1", arguments: {"name": "liao", "age": 33});
            },
            child: const Text("路由跳转"),
          ),
        ],
      ),
    );
  }
}
