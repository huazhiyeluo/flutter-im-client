import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/widget/custom_search_field.dart';

class Share extends StatefulWidget {
  const Share({super.key});

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  bool isSingle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择一个聊天"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isSingle = !isSingle;
              });
            },
            child: Text(isSingle ? '多选' : '单选'),
          )
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.grey[200],
              pinned: false,
              expandedHeight: 210,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.all(10),
                      child: CustomSearchField(
                        controller: inputController,
                        hintText: '搜索',
                        expands: false,
                        maxHeight: 40,
                        minHeight: 40,
                        onTap: () {
                          // 处理点击事件的逻辑
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      color: Colors.white,
                      child: const Row(
                        children: [
                          Text(
                            "最近转发",
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            height: 90,
                            width: 80,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        CachedNetworkImageProvider('http://img.siyuwen.com/godata/avatar/210.jpg'),
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    "秋风我最新",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 90,
                            width: 80,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        CachedNetworkImageProvider('http://img.siyuwen.com/godata/avatar/200.jpg'),
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    "秋风我最",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 40.0, // 最小高度
                maxHeight: 40.0, // 最大高度
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "最近聊天",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      TextButton.icon(
                        label: const Text("创建新的聊天"),
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/share-select',
                          );
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: SharePage(
          scrollController: _scrollController,
        ),
      ),
    );
  }
}

class SharePage extends StatefulWidget {
  final ScrollController scrollController;
  const SharePage({super.key, required this.scrollController});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final ChatController chatController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
          itemCount: chatController.allShowChats.length,
          itemBuilder: (BuildContext context, int index) {
            var temp = chatController.allShowChats[index];
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: false,
                          onChanged: (bool? value) {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          temp['icon'],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(temp["remark"] != '' ? temp["remark"] : temp["name"]),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey[100],
                )
              ],
            );
          });
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
