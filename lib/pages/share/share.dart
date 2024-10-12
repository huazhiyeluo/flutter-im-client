import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/db.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/data/api/common.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/share.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/widget/custom_search_field.dart';
import 'package:qim/common/widget/dialog_confirm.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;

class Share extends StatefulWidget {
  const Share({super.key});

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> with SingleTickerProviderStateMixin {
  final WebSocketController webSocketController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();
  final ChatController chatController = Get.find();
  final ShareController shareController = Get.find();
  final TextEditingController nameCtr = TextEditingController();
  final UserInfoController userInfoController = Get.find();

  bool isSingle = true;

  Map msgObj = {};
  int uid = 0;
  Map userInfo = {};
  int ttype = 1; //1、正常 2、要处理文件上传问题

  List _cateShareArrs = [];
  List _cateChatArrs = [];
  final List<Map> _userSelectArrs = [];

  @override
  void initState() {
    super.initState();

    if (Get.arguments != null) {
      msgObj = Get.arguments['msgObj'];
      ttype = Get.arguments['ttype'];

    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    _initData();
  }

  void _initData() async {
    if (shareController.allShares.isEmpty) {
      List shares = await DBHelper.getData('share', [], orderBy: 'operateTime DESC', limit: 10);
      for (var item in shares) {
        shareController.upsetShare(item);
      }
    }
    for (var shareObj in shareController.allShares) {
      Map temp = Map.from(shareObj);
      temp['isSelect'] = false;
      temp['isHidden'] = false;
      _cateShareArrs.add(temp);
    }

    for (var chatObj in chatController.allShowChats) {
      Map temp = Map.from(chatObj);
      temp['isSelect'] = false;
      temp['isHidden'] = false;
      _cateChatArrs.add(temp);
    }

    setState(() {});
  }

  void _changeTo() {
    _userSelectArrs.clear();
    for (var it in _cateChatArrs) {
      it['isSelect'] = false;
    }
    for (var it in _cateShareArrs) {
      it['isSelect'] = false;
    }
    setState(() {
      isSingle = !isSingle;
    });
  }

  Widget _getToSends() {
    List arr = [];
    for (var it in _userSelectArrs) {
      arr.add(it['remark'] != "" ? it['remark'] : it['name']);
    }
    String str = arr.join(', ');
    return Text(
      str,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _getOpt() {
    Widget temp = const Text("多选");
    if (!isSingle) {
      if (_userSelectArrs.isNotEmpty) {
        temp = TextButton(
          onPressed: _send,
          child: Text("发送(${_userSelectArrs.length})人"),
        );
      } else {
        temp = const Text("单选");
      }
    }
    return temp;
  }

  // 多选处理_userSelectArrs  ，如果是单选发送消息
  void _setSelected(int objId, int type) {
    if (isSingle) {
      _userSelectArrs.clear();
    }

    bool flag = false;
    final existingIndex = _userSelectArrs.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingIndex != -1) {
      flag = true;
      _userSelectArrs.removeAt(existingIndex);
    }

    Map temp = {};
    for (var it in _cateChatArrs) {
      if (it['objId'] == objId && it['type'] == type) {
        it['isSelect'] = !flag;
        temp = it;
      }
    }
    for (var it in _cateShareArrs) {
      if (it['objId'] == objId && it['type'] == type) {
        it['isSelect'] = !flag;
        temp = it;
      }
    }

    if (existingIndex == -1) {
      _userSelectArrs.add(temp);
    }

    setState(() {
      _cateChatArrs = _cateChatArrs;
      _cateShareArrs = _cateShareArrs;
    });

    if (isSingle) {
      _send();
    }
  }

  Future<void> _updateUrl() async {
    final String filePath = msgObj["content"]["url"];
    final File tempFile = File(filePath);

    final dio.MultipartFile file = await dio.MultipartFile.fromFile(
      tempFile.path,
      filename: path.basename(filePath), // 使用文件名
    );

    Completer<void> completer = Completer<void>();

    CommonApi.upload({'file': file}, onSuccess: (res) async {
      msgObj["content"]["url"] = res['data'];
      setState(() {
        msgObj = msgObj;
      });
      await tempFile.delete();
      completer.complete();
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      completer.complete();
    });

    return completer.future;
  }

  // 创建新的聊天 -转发
  Future<void> _selectMore() async {
    final result = await Navigator.pushNamed(
      context,
      '/share-select',
    );

    if (result != null && result is Map) {
      setState(() {
        _userSelectArrs.addAll(result['_userSelectArrs'] as List<Map>);
      });
      _send();
    }
  }

  // 发送消息
  void _send() {
    showCustomDialog(
      context: context,
      content: Container(
        constraints: const BoxConstraints(maxHeight: 160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_userSelectArrs.length == 1 ? "发送给：" : "分别发送给：", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 10,
            ),
            _getToSends(),
            const SizedBox(
              height: 10,
            ),
            Text(
              getContent(msgObj['msgMedia'], msgObj['content']),
              maxLines: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: nameCtr,
              decoration: const InputDecoration(hintText: "给朋友留言"),
            )
          ],
        ),
      ),
      onConfirm: () async {
        if (ttype == 2) {
          await _updateUrl();
        }
        for (var it in _userSelectArrs) {
          msgObj["id"] = genGUID();
          msgObj["fromId"] = uid;
          msgObj["toId"] = it['objId'];
          msgObj["msgType"] = it['type'];
          msgObj['createTime'] = getTime();
          webSocketController.sendMessage(msgObj);
          if (![1, 2].contains(msgObj['msgType'])) {
            return;
          }
          joinData(uid, msgObj);

          if (nameCtr.text.trim() != "") {
            Map msg = {
              'id': genGUID(),
              'fromId': uid,
              'toId': it['objId'],
              'content': {"data": nameCtr.text, "url": "", "name": ""},
              'msgMedia': 1,
              'msgType': it['type'],
              'createTime': getTime()
            };
            webSocketController.sendMessage(msg);
            if (![1, 2].contains(msg['msgType'])) {
              return;
            }
            joinData(uid, msg);
          }

          joinShare(it);
        }

        if (!mounted) return;
        _userSelectArrs.clear();
        Navigator.pop(context);
      },
      onConfirmText: "发送",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择一个聊天"),
        actions: [
          TextButton(
            onPressed: () {
              _changeTo();
            },
            child: _getOpt(),
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
                        onTap: () {},
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
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // 水平滚动
                        itemCount: _cateShareArrs.length, // 根据数据的长度生成项目
                        itemBuilder: (context, index) {
                          // 获取当前项目的数据
                          final item = _cateShareArrs[index];
                          return Container(
                            height: 90,
                            width: 80,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                _setSelected(item['objId'], item['type']);
                              },
                              child: Stack(
                                children: [
                                  // 头像和文字区域
                                  SizedBox(
                                    height: 85,
                                    width: 80,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min, // 保证 Column 大小自适应内容
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: CachedNetworkImageProvider(item['icon']),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          item["remark"].isNotEmpty ? item["remark"] : item["name"], // 使用数组中的名称
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Checkbox 顶部右对齐
                                  if (!isSingle)
                                    Positioned(
                                      left: 17,
                                      top: -15,
                                      child: SizedBox(
                                        child: Transform.scale(
                                          scale: 1.0,
                                          child: Checkbox(
                                            value: item['isSelect'],
                                            onChanged: (bool? value) {
                                              _setSelected(item['objId'], item['type']); // 处理选中事件
                                            },
                                            side: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.padded,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
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
                          _selectMore();
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
        body: ListView.builder(
          itemCount: _cateChatArrs.length,
          itemBuilder: (BuildContext context, int index) {
            var item = _cateChatArrs[index];
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: InkWell(
                    onTap: () {
                      _setSelected(item['objId'], item['type']);
                    },
                    child: Row(
                      children: [
                        !isSingle
                            ? SizedBox(
                                height: 40,
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: item['isSelect'],
                                    onChanged: (bool? value) {
                                      _setSelected(item['objId'], item['type']);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 10,
                              ),
                        SizedBox(
                          height: 40,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                              item['icon'],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(item["remark"] != '' ? item["remark"] : item["name"]),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey[100],
                )
              ],
            );
          },
        ),
      ),
    );
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
