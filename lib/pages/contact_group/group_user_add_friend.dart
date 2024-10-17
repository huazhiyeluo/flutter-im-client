import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/widget/custom_search_field.dart';

class UserModel extends ISuspensionBean {
  int? uid;
  String? name;
  String? icon;
  String? info;
  String? remark;
  String? tagIndex; // 这个字段就是tag
  String? namePinyin;
  int? isContact;

  @override
  String getSuspensionTag() => tagIndex!;
}

class GroupUserAddFriend extends StatefulWidget {
  const GroupUserAddFriend({super.key});

  @override
  State<GroupUserAddFriend> createState() => _GroupUserAddFriendState();
}

class _GroupUserAddFriendState extends State<GroupUserAddFriend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加好友"),
      ),
      body: const GroupUserAddFriendPage(),
    );
  }
}

class GroupUserAddFriendPage extends StatefulWidget {
  const GroupUserAddFriendPage({super.key});

  @override
  State<GroupUserAddFriendPage> createState() => _GroupUserAddFriendPageState();
}

class _GroupUserAddFriendPageState extends State<GroupUserAddFriendPage> {
  final UserInfoController userInfoController = Get.find();
  final UserController userController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  final TextEditingController _inputController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  List<UserModel> _userArr = [];

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    _formatData();
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  void _formatData() {
    final contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);
    _userArr.clear();
    for (var item in contactGroups) {
      Map userObj = userController.getOneUser(item['fromId']);
      Map contactFriendObj = contactFriendController.getOneContactFriend(uid, item['fromId']);
      if (userObj['nickname'].contains(_inputController.text) || item['remark'].contains(_inputController.text) || item['fromId'].toString().contains(_inputController.text)) {
        UserModel chat = UserModel();
        chat.uid = item['fromId'];
        chat.name = userObj['nickname'];
        chat.icon = userObj['avatar'];
        chat.info = userObj['info'];
        chat.remark = item['remark'];
        chat.isContact = contactFriendObj.isEmpty ? 0 : 1;
        chat.namePinyin = PinyinHelper.getPinyin(item['remark'] != '' ? item['remark'] : userObj['nickname']);
        String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
        chat.tagIndex = firstLetter.toUpperCase();
        _userArr.add(chat);
      }
    }
    setState(() {
      _userArr = _userArr;
    });

    SuspensionUtil.sortListBySuspensionTag(_userArr);
    SuspensionUtil.setShowSuspensionStatus(_userArr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: AppBar(
          automaticallyImplyLeading: false,
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
      body: AzListView(
        data: _userArr,
        itemCount: _userArr.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 65,
                child: ListTile(
                  leading: CircleAvatar(
                    // 聊天对象的头像
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(
                      _userArr[index].icon!,
                    ),
                  ),
                  title: Text('${_userArr[index].remark != "" ? _userArr[index].remark : _userArr[index].name}'),
                  trailing: _userArr[index].uid == uid
                      ? const Text("自己")
                      : _userArr[index].isContact == 0
                          ? TextButton(
                              onPressed: () {
                                Map userObj = {};
                                userObj['uid'] = _userArr[index].uid;
                                userObj['nickname'] = _userArr[index].name;
                                userObj['avatar'] = _userArr[index].icon;
                                userObj['info'] = _userArr[index].info;
                                Navigator.pushNamed(
                                  context,
                                  '/add-contact-friend-do',
                                  arguments: userObj,
                                );
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0), // 设置按钮的圆角
                                    side: const BorderSide(color: Colors.grey), // 设置按钮的边框颜色和宽度
                                  ),
                                ),
                              ),
                              child: const Text(
                                "添加",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : const Text(""),
                  onTap: () {},
                ),
              ),
            ],
          );
        },
        susItemBuilder: (BuildContext context, int index) {
          UserModel model = _userArr[index];
          String tag = model.getSuspensionTag();
          if ('★' == model.getSuspensionTag()) {
            return Container();
          }
          return Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 15.0),
            color: const Color(0xfff3f4f5),
            alignment: Alignment.centerLeft,
            child: Text(
              tag,
              softWrap: false,
              style: const TextStyle(fontSize: 14.0, color: Color(0xff999999)),
            ),
          );
        },
        indexBarData: SuspensionUtil.getTagIndexList(_userArr),
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: Text(
              hint,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
