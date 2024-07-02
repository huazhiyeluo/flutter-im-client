import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  final String title;
  const Test2(this.title, {super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print(args);

    return Scaffold(
      appBar: AppBar(
          title: const SizedBox(
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: "笔记本",
                hintStyle: TextStyle(fontSize: 14),
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
          actions: [TextButton(onPressed: () {}, child: const Text("搜索"))]),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Row(
            children: [
              Text("热搜", style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const Divider(),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MyTextButton("女装"),
              MyTextButton("女装"),
              MyTextButton("笔记本电脑"),
              MyTextButton("女装"),
              MyTextButton("女装"),
              MyTextButton("女装")
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text("历史记录", style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const Column(
            children: [
              ListTile(
                title: Text("女装"),
              ),
              Divider(),
              ListTile(
                title: Text("男装"),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          OutlinedButton.icon(
            onPressed: () {},
            label: const Text("清空历史记录"),
            icon: const Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}

class MyTextButton extends StatefulWidget {
  final String title;
  const MyTextButton(
    this.title, {
    super.key,
  });

  @override
  State<MyTextButton> createState() => _MyTextButtonState();
}

class _MyTextButtonState extends State<MyTextButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: Text(widget.title));
  }
}
