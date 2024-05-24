import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/widget/custom_text_field.dart';

class NoticeGroupModel extends ISuspensionBean {
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

class NoticeGroup extends StatefulWidget {
  const NoticeGroup({super.key});

  @override
  State<NoticeGroup> createState() => _NoticeGroupState();
}

class _NoticeGroupState extends State<NoticeGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("群通知"),
        backgroundColor: Colors.grey[100],
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("清空"),
          ),
        ],
      ),
      body: const NoticeGroupPage(),
    );
  }
}

class NoticeGroupPage extends StatefulWidget {
  const NoticeGroupPage({super.key});

  @override
  State<NoticeGroupPage> createState() => _NoticeGroupPageState();
}

class _NoticeGroupPageState extends State<NoticeGroupPage> {
  final TextEditingController inputController = TextEditingController();

  final List<NoticeGroupModel> _NoticeGroupArr = [];

  @override
  void initState() {
    super.initState();

    for (var item in Get.arguments) {
      NoticeGroupModel chat = NoticeGroupModel();
      chat.uid = item['uid'];
      chat.name = item['NoticeGroupname'];
      chat.icon = item['avatar'];
      chat.info = item['info'];
      chat.remark = item['remark'];
      chat.namePinyin = PinyinHelper.getPinyin(item['NoticeGroupname']);
      String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
      chat.tagIndex = firstLetter.toUpperCase();
      _NoticeGroupArr.add(chat);
    }

    _NoticeGroupArr.sort((a, b) => a.tagIndex!.compareTo(b.tagIndex!));
    SuspensionUtil.setShowSuspensionStatus(_NoticeGroupArr);
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
        data: _NoticeGroupArr,
        itemCount: _NoticeGroupArr.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 65,
                child: ListTile(
                  leading: CircleAvatar(
                    // 聊天对象的头像
                    radius: 20,
                    backgroundImage: NetworkImage(_NoticeGroupArr[index].icon!),
                  ),
                  title: Text(
                      '${_NoticeGroupArr[index].remark != "" ? _NoticeGroupArr[index].remark : _NoticeGroupArr[index].name}'),
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
          NoticeGroupModel model = _NoticeGroupArr[index];
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
        indexBarData: SuspensionUtil.getTagIndexList(_NoticeGroupArr),
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
