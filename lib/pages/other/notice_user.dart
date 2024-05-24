import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/widget/custom_text_field.dart';

class NoticeUserModel extends ISuspensionBean {
  int? uid;
  String? name;
  String? icon;
  String? info;
  String? remark;
  String? tagIndex; // 这个字段就是tag
  String? namePinyin;

  @override
  String getSuspensionTag() => tagIndex!;
}

class NoticeUser extends StatefulWidget {
  const NoticeUser({super.key});

  @override
  State<NoticeUser> createState() => _NoticeUserState();
}

class _NoticeUserState extends State<NoticeUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新朋友"),
        backgroundColor: Colors.grey[100],
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("添加"),
          ),
        ],
      ),
      body: const NoticeUserPage(),
    );
  }
}

class NoticeUserPage extends StatefulWidget {
  const NoticeUserPage({super.key});

  @override
  State<NoticeUserPage> createState() => _NoticeUserPageState();
}

class _NoticeUserPageState extends State<NoticeUserPage> {
  final TextEditingController inputController = TextEditingController();

  final List<NoticeUserModel> _NoticeUserArr = [];

  @override
  void initState() {
    super.initState();

    for (var item in Get.arguments) {
      NoticeUserModel chat = NoticeUserModel();
      chat.uid = item['uid'];
      chat.name = item['NoticeUsername'];
      chat.icon = item['avatar'];
      chat.info = item['info'];
      chat.remark = item['remark'];
      chat.namePinyin = PinyinHelper.getPinyin(item['NoticeUsername']);
      String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
      chat.tagIndex = firstLetter.toUpperCase();
      _NoticeUserArr.add(chat);
    }

    _NoticeUserArr.sort((a, b) => a.tagIndex!.compareTo(b.tagIndex!));
    SuspensionUtil.setShowSuspensionStatus(_NoticeUserArr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: CustomTextField(
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
      ),
      body: AzListView(
        data: _NoticeUserArr,
        itemCount: _NoticeUserArr.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 65,
                child: ListTile(
                  leading: CircleAvatar(
                    // 聊天对象的头像
                    radius: 20,
                    backgroundImage: NetworkImage(_NoticeUserArr[index].icon!),
                  ),
                  title: Text(
                      '${_NoticeUserArr[index].remark != "" ? _NoticeUserArr[index].remark : _NoticeUserArr[index].name}'),
                  trailing: TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
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
                  ),
                  onTap: () {},
                ),
              ),
            ],
          );
        },
        susItemBuilder: (BuildContext context, int index) {
          NoticeUserModel model = _NoticeUserArr[index];
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
        indexBarData: SuspensionUtil.getTagIndexList(_NoticeUserArr),
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
