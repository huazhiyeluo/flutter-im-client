import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Test1 extends StatefulWidget {
  final Map arguments;
  const Test1({super.key, required this.arguments});

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print(args);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo"),
      ),
      body: Container(
        child: ListView(
          children: [
            Card(
              elevation: 10,
              shadowColor: Colors.yellow,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              margin: const EdgeInsets.all(10),
              child: Column(children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    "http://139.196.98.139:8081/static/images/926dbf242cb455a403972f247f7bedfd.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text("李明"),
                  subtitle: const Text("PHP软件工程师"),
                  leading: const CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        NetworkImage("http://139.196.98.139:8081/static/images/926dbf242cb455a403972f247f7bedfd.jpg"),
                  ),
                  trailing: ClipOval(
                    child:
                        Image.network("http://139.196.98.139:8081/static/images/926dbf242cb455a403972f247f7bedfd.jpg"),
                  ),
                ),
                Container(
                  width: 200,
                  height: 100,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {},
                    child: const Text("测试"),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up),
                  tooltip: "121",
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                TextButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
              ]),
            ),
            const Card(
              color: Colors.green,
              elevation: 10,
              shadowColor: Colors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Text("李明"),
                    subtitle: Text("PHP软件工程师"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("18503041919"),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("儿童玩具"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(alignment: Alignment.center),
                  onPressed: () {},
                  label: const Text("成人玩具"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("搜索"),
                  icon: const Icon(Icons.search),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
