import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/savedata.dart';
import 'package:qim/utils/tips.dart';
import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/widget/custom_text_field.dart';

class ChatModel extends ISuspensionBean {
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

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> with SingleTickerProviderStateMixin {
  final TextEditingController inputController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
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
          bottom: TabBar(
            padding: const EdgeInsets.all(0),
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            controller: _tabController,
            tabs: const [
              Tab(
                child: Text("好友"),
              ),
              Tab(
                child: Text("分组"),
              ),
              Tab(
                child: Text("群聊"),
              ),
            ],
          ),
        ),
      ),
      body: ContactPage(
        tabController: _tabController,
      ),
    );
  }
}

class ContactPage extends StatefulWidget {
  final TabController tabController;
  const ContactPage({super.key, required this.tabController});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TalkobjController talkobjController = Get.put(TalkobjController());

  final List<ChatModel> _firendArr = [];
  List _groupArr = [];
  List _contactGroupArr = [];

  Map isExpandeds = {}; // 初始化展开状态
  int uid = 0;

  @override
  void initState() {
    super.initState();
    Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
    uid = userInfo == null ? "" : userInfo['uid'];

    _getFriendList();
    _getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: widget.tabController, children: [
      AzListView(
        data: _firendArr,
        itemCount: _firendArr.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 65,
                child: ListTile(
                  leading: CircleAvatar(
                    // 聊天对象的头像
                    radius: 20,
                    backgroundImage: NetworkImage(_firendArr[index].icon!),
                  ),
                  title: Text('${_firendArr[index].remark != "" ? _firendArr[index].remark : _firendArr[index].name}'),
                  subtitle: Text(
                    _firendArr[index].info ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Map talkobj = {
                      "objId": _firendArr[index].uid,
                      "type": 1,
                      "name": _firendArr[index].name,
                      "icon": _firendArr[index].icon,
                      "info": _firendArr[index].info,
                      "remark": _firendArr[index].remark != "" ? _firendArr[index].remark : _firendArr[index].name,
                    };
                    talkobjController.setTalkObj(talkobj);
                    Navigator.pushNamed(
                      context,
                      '/talk',
                    );
                  },
                ),
              ),
            ],
          );
        },
        susItemBuilder: (BuildContext context, int index) {
          ChatModel model = _firendArr[index];
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
        indexBarData: SuspensionUtil.getTagIndexList(_firendArr),
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
      ListView.builder(
        itemCount: _contactGroupArr.length, // Replace with actual count
        itemBuilder: (BuildContext context, int index) {
          if (isExpandeds[index] == null) {
            isExpandeds[index] = false;
          }
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(_contactGroupArr[index]['name']),
              controlAffinity: ListTileControlAffinity.leading,
              leading: Icon(
                isExpandeds[index] ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 36,
                color: Colors.red,
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  isExpandeds[index] = expanded;
                });
              },
              maintainState: isExpandeds[index],
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contactGroupArr[index]['children'].length,
                  itemBuilder: (BuildContext context, int indexc) {
                    var ctemp = _contactGroupArr[index]['children'][indexc];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(ctemp['avatar']),
                            ),
                            title: Text(ctemp['remark'] != "" ? ctemp['remark'] : ctemp['username']),
                            subtitle: Text(
                              ctemp['info'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Map talkobj = {
                                "objId": ctemp['uid'],
                                "type": 1,
                                "name": ctemp['username'],
                                "icon": ctemp['avatar'],
                                "info": ctemp['info'],
                                "remark": ctemp['remark'] != "" ? ctemp['remark'] : ctemp['username'],
                              };
                              talkobjController.setTalkObj(talkobj);
                              Navigator.pushNamed(
                                context,
                                '/talk',
                              );
                            },
                          ),
                          const Divider(), // 在ListTile下方添加分隔线
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      ListView.builder(
        itemCount: _groupArr.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
            child: Column(children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_groupArr[index]['icon']),
                ),
                title: Text(_groupArr[index]['remark'] != "" ? _groupArr[index]['remark'] : _groupArr[index]['name']),
                subtitle: Text(
                  _groupArr[index]['info'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Map talkobj = {
                    "objId": _groupArr[index]['groupId'],
                    "type": 2,
                    "name": _groupArr[index]['name'],
                    "icon": _groupArr[index]['icon'],
                    "info": _groupArr[index]['info'],
                    "remark": _groupArr[index]['remark'] != "" ? _groupArr[index]['remark'] : _groupArr[index]['name'],
                  };
                  talkobjController.setTalkObj(talkobj);
                  Navigator.pushNamed(
                    context,
                    '/talk',
                  );
                },
              ),
              const Divider(), // 在ListTile下方添加分隔线
            ]),
          );
        },
      ),
    ]);
  }

  // 内部方法
  void _getFriendList() async {
    var params = {
      'fromId': uid,
    };
    ContactApi.getFriendList(params, onSuccess: (res) {
      setState(() {
        List friendArr = [];
        if (res['data'] != null) {
          friendArr = res['data'];
        }
        // 遍历friendArr
        for (var item in friendArr) {
          ChatModel chat = ChatModel();
          chat.uid = item['uid'];
          chat.name = item['username'];
          chat.icon = item['avatar'];
          chat.info = item['info'];
          chat.remark = item['remark'];
          chat.namePinyin = PinyinHelper.getPinyin(item['username']);
          String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
          chat.tagIndex = firstLetter.toUpperCase();
          _firendArr.add(chat);

          saveUser(item); //数据库存贮
        }

        _firendArr.sort((a, b) => a.tagIndex!.compareTo(b.tagIndex!));
        SuspensionUtil.setShowSuspensionStatus(_firendArr);

        ContactApi.getFriendGroup({"ownUid": uid}, onSuccess: (res) {
          setState(() {
            if (res['data'] != null) {
              _contactGroupArr = res['data'];
            }
            _contactGroupArr.insert(0, {"friendGroupId": 0, "name": "默认分组"});
            for (var item in _contactGroupArr) {
              for (var citem in friendArr) {
                if (citem['friendGroupId'] == item['friendGroupId']) {
                  if (item['children'] == null) {
                    item['children'] = [];
                  }
                  item['children'].add(citem);
                }
              }
            }
          });
        }, onError: (err) {
          TipHelper.instance.showToast(res['msg']);
        });
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _getGroupList() async {
    var params = {
      'fromId': uid,
    };
    ContactApi.getGroupList(params, onSuccess: (res) {
      setState(() {
        if (res['data'] != null) {
          _groupArr = res['data'];
        }
        for (var item in _groupArr) {
          saveGroup(item); //数据库存贮
        }
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
