import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_search_field.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: AppBar(
          backgroundColor: Colors.grey[200],
          flexibleSpace: Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 5),
            child: CustomSearchField(
              controller: _inputController,
              hintText: '搜索',
              expands: false,
              maxHeight: 40,
              minHeight: 40,
              onTap: () {},
            ),
          ),
        ),
      ),
      body: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final UserInfoController userInfoController = Get.find();
  final ChatController chatController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  late final int uid;
  late final Map userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  void _setTop(Map temp) {
    Map chatData = {
      'objId': temp['objId'],
      'type': temp['type'],
      'isTop': 1 - temp['isTop'],
    };
    chatController.upsetChat(chatData);
    saveDbChat(chatData);
    _actContact(temp['objId'], 'isTop', chatData['isTop'], temp['type']);
  }

  void _markAsRead(Map temp) {
    Map chatData = {
      'objId': temp['objId'],
      'type': temp['type'],
      'tips': 0,
    };
    chatController.upsetChat(chatData);
    saveDbChat(chatData);
  }

  void _deleteChat(Map temp) {
    chatController.delChat(temp['objId'], temp['type']);
    delDbChat(temp['objId'], temp['type']);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: chatController.allShowChats.length,
        itemBuilder: (BuildContext context, int index) {
          var temp = chatController.allShowChats[index];
          bool isTop = temp['isTop'] == 1;
          return Slidable(
            key: ValueKey(temp['objId']),
            useTextDirection: false,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: isTop ? 0.75 : 0.6,
              children: [
                _buildSlidableAction(
                  onPressed: () => _setTop(temp),
                  backgroundColor: Colors.blue,
                  text: isTop ? '取消置顶' : '置顶',
                ),
                _buildSlidableAction(
                  onPressed: () => _markAsRead(temp),
                  backgroundColor: Colors.green,
                  text: '标为已读',
                ),
                _buildSlidableAction(
                  onPressed: () => _deleteChat(temp),
                  backgroundColor: Colors.red,
                  text: '删除',
                ),
              ],
            ),
            child: _buildChatItem(temp),
          );
        },
      );
    });
  }

  Widget _buildSlidableAction({required Function onPressed, required Color backgroundColor, required String text}) {
    return CustomSlidableAction(
      padding: EdgeInsets.zero,
      flex: 4,
      onPressed: (slidCtx) => onPressed(),
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      child: Center(child: Text(text, textDirection: TextDirection.ltr, textAlign: TextAlign.center)),
    );
  }

  Widget _buildChatItem(Map temp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: const Border(
          bottom: BorderSide(color: Color.fromARGB(255, 203, 201, 201), width: 1.0),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(temp["icon"]),
        ),
        title: Text(temp["remark"].isNotEmpty ? temp["remark"] : temp["name"]),
        subtitle: Text(
          getContent(temp["msgMedia"], temp["content"]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          children: [
            const SizedBox(height: 5),
            Text(
              getSpecialDate(temp["operateTime"]),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 5),
            temp['isQuiet'] == 1
                ? const Icon(Icons.notifications_off_outlined)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: temp["type"] == 1 ? Colors.red[200] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${temp["tips"]}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
          ],
        ),
        onTap: () {
          _markAsRead(temp);
          Map talkObj = {
            "objId": temp["objId"],
            "type": temp["type"],
          };
          Navigator.pushNamed(context, '/talk', arguments: talkObj);
        },
      ),
    );
  }

  void _actContact(int toId, String field, int value, int type) {
    var params = {
      'fromId': uid,
      'toId': toId,
      field: value,
    };
    if (type == ObjectTypes.user) {
      ContactFriendApi.actContactFriend(params, onSuccess: (res) {
        contactFriendController.upsetContactFriend(res['data']);
        saveDbContactFriend(res['data']);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    } else if (type == ObjectTypes.group) {
      ContactGroupApi.actContactGroup(params, onSuccess: (res) {
        contactGroupController.upsetContactGroup(res['data']);
        saveDbContactGroup(res['data']);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }
}
