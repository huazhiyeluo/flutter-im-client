import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/utils/cache.dart';
import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/widget/custom_text_field.dart';

class ChatModel extends ISuspensionBean {
  int? uid;
  String? name;
  String? icon;
  String? info;
  int? isOnline;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: false,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      child: CustomTextField(
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
                      height: 40,
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/notice-user',
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '新朋友',
                                style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/notice-group',
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '群通知',
                                style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  tabs: const [
                    Tab(text: '好友'),
                    Tab(text: '分组'),
                    Tab(text: '群聊'),
                  ],
                  controller: _tabController,
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
            ),
          ];
        },
        body: ContactPage(
          tabController: _tabController,
        ),
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
  final TalkobjController talkobjController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final UserController userController = Get.find();
  final GroupController groupController = Get.find();

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

    _groupArr = groupController.allGroups;

    // 监听 userController 和 contactGroupController 的数据变化
    ever(userController.allUsers, (_) => _formatData());
    ever(contactGroupController.allContactGroups, (_) => _formatData());

    _formatData();
  }

  void _formatData() {
    _firendArr.clear();
    for (var item in userController.allUsers) {
      ChatModel chat = ChatModel();
      chat.uid = item['uid'];
      chat.name = item['username'];
      chat.icon = item['avatar'];
      chat.info = item['info'];
      chat.remark = item['remark'];
      chat.isOnline = item['isOnline'];
      chat.namePinyin = PinyinHelper.getPinyin(item['username']);
      String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
      chat.tagIndex = firstLetter.toUpperCase();
      _firendArr.add(chat);
    }
    setState(() {
      _firendArr.sort((a, b) => a.tagIndex!.compareTo(b.tagIndex!));
      SuspensionUtil.setShowSuspensionStatus(_firendArr);
    });
    _contactGroupArr.clear();
    _contactGroupArr = List.from(contactGroupController.allContactGroups);
    for (var item in _contactGroupArr) {
      item['children'] = [];
      for (var citem in userController.allUsers) {
        if (citem['friendGroupId'] == item['friendGroupId']) {
          if (item['children'] == null) {
            item['children'] = [];
          }
          item['children'].add(citem);
        }
      }
    }
    setState(() {
      _contactGroupArr = _contactGroupArr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: widget.tabController, children: [
      SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: AzListView(
            data: _firendArr,
            itemCount: _firendArr.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: ListTile(
                      leading: CircleAvatar(
                        // 聊天对象的头像
                        radius: 20,
                        backgroundImage: NetworkImage(_firendArr[index].icon!),
                      ),
                      title:
                          Text('${_firendArr[index].remark != "" ? _firendArr[index].remark : _firendArr[index].name}'),
                      subtitle: Text(
                        "[${_firendArr[index].isOnline == 1 ? '在线' : '离线'}] ${_firendArr[index].info}",
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
        ),
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
                              "[${ctemp['isOnline'] == 1 ? '在线' : '离线'}] ${ctemp['info']}",
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
