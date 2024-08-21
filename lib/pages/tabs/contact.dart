import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/apply.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/friend_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qim/widget/custom_search_field.dart';

class ChatModel extends ISuspensionBean {
  int? toId;
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
  final ApplyController applyController = Get.find();
  final TextEditingController inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool showFriendRedPoint = false;
  bool showGroupRedPoint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    ever(applyController.showFriendRedPoint, (_) => _formatData(1));
    ever(applyController.showGroupRedPoint, (_) => _formatData(2));
    _formatData(1);
    _formatData(2);
  }

  _formatData(int type) {
    if (!mounted) return;
    setState(() {
      if (type == 1) {
        showFriendRedPoint = applyController.showFriendRedPoint.value;
      }
      if (type == 2) {
        showGroupRedPoint = applyController.showGroupRedPoint.value;
      }
    });
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
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: false,
              expandedHeight: 170,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
                      height: 45,
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/notice-user',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '新朋友',
                                style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
                              ),
                              Expanded(child: Container()),
                              showFriendRedPoint
                                  ? Container(
                                      height: 12,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: 12,
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                    )
                                  : Container(),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/notice-group',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '群通知',
                                style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
                              ),
                              Expanded(child: Container()),
                              showGroupRedPoint
                                  ? Container(
                                      height: 12,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: 12,
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                    )
                                  : Container(),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                      padding: EdgeInsets.zero,
                      color: const Color.fromARGB(136, 238, 237, 237),
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
          scrollController: _scrollController,
        ),
      ),
    );
  }
}

class ContactPage extends StatefulWidget {
  final TabController tabController;
  final ScrollController scrollController;
  const ContactPage({super.key, required this.tabController, required this.scrollController});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final UserController userController = Get.put(UserController());
  final GroupController groupController = Get.put(GroupController());

  List<ChatModel> _tabArr1 = [];
  List _tabArr2 = [];
  List _tabArr3 = [];

  Map isExpandeds = {}; // 初始化展开状态
  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    // 监听 friendController 和 friendGroupController 的数据变化
    ever(friendGroupController.allFriendGroups, (_) => _formatData());
    ever(contactFriendController.allContactFriends, (_) => _formatData());
    ever(contactGroupController.allContactGroups, (_) => _formatData());

    _formatData();
  }

  @override
  void dispose() {
    // 取消订阅
    super.dispose();
  }

  void _formatData() {
    _tabArr1.clear();
    for (var contactFriendObj in contactFriendController.allContactFriends) {
      ChatModel chat = ChatModel();

      Map? userObj = userController.getOneUser(contactFriendObj['toId'])!;

      chat.toId = contactFriendObj['toId'];
      chat.name = userObj['nickname'];
      chat.icon = userObj['avatar'];
      chat.info = userObj['info'];
      chat.remark = contactFriendObj['remark'];
      chat.isOnline = contactFriendObj['isOnline'];
      chat.namePinyin =
          PinyinHelper.getPinyin(contactFriendObj['remark'] != "" ? contactFriendObj['remark'] : userObj['nickname']);
      String firstLetter = PinyinHelper.getFirstWordPinyin(chat.namePinyin!);
      chat.tagIndex = firstLetter.toUpperCase();
      _tabArr1.add(chat);
    }
    SuspensionUtil.sortListBySuspensionTag(_tabArr1);
    SuspensionUtil.setShowSuspensionStatus(_tabArr1);

    _tabArr2.clear();
    _tabArr2 = List.from(friendGroupController.allFriendGroups);
    for (var friendGroupObj in _tabArr2) {
      friendGroupObj['children'] = [];
      for (var contactFriendObj in contactFriendController.allContactFriends) {
        if (contactFriendObj['friendGroupId'] == friendGroupObj['friendGroupId']) {
          if (friendGroupObj['children'] == null) {
            friendGroupObj['children'] = [];
          }
          Map userObj = userController.getOneUser(contactFriendObj['toId'])!;
          contactFriendObj['name'] = userObj['nickname'];
          contactFriendObj['icon'] = userObj['avatar'];
          contactFriendObj['info'] = userObj['info'];
          friendGroupObj['children'].add(contactFriendObj);
        }
      }
    }

    _tabArr3.clear();
    _tabArr3 = List.from(groupController.allGroups);
    for (var item in _tabArr3) {
      Map? tempContactGroup = contactGroupController.getOneContactGroup(uid, item['groupId']);
      item['fromId'] = uid;
      item['toId'] = item['groupId'];
      item['remark'] = tempContactGroup?['remark'];
    }
    if (!mounted) return;
    setState(() {
      _tabArr1 = _tabArr1;
      _tabArr2 = _tabArr2;
      _tabArr3 = _tabArr3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: widget.tabController, children: [
      AzListView(
        data: _tabArr1,
        itemCount: _tabArr1.length,
        itemBuilder: (context, index) {
          ChatModel itemFriend = _tabArr1[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(itemFriend.icon!),
            ),
            title: Text(
              '${itemFriend.remark != "" ? itemFriend.remark : itemFriend.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "[${itemFriend.isOnline == 1 ? '在线' : '离线'}] ${itemFriend.info}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Map talkobj = {
                "objId": itemFriend.toId,
                "type": 1,
              };
              Navigator.pushNamed(context, '/friend-detail', arguments: talkobj);
            },
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          );
        },
        padding: EdgeInsets.zero,
        susItemBuilder: (BuildContext context, int index) {
          ChatModel model = _tabArr1[index];
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
        indexBarData: SuspensionUtil.getTagIndexList(_tabArr1),
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration: const BoxDecoration(
              color: Colors.blue,
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
        itemCount: _tabArr2.length, // Replace with actual count
        itemBuilder: (BuildContext context, int index) {
          if (isExpandeds[index] == null) {
            isExpandeds[index] = false;
          }
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(_tabArr2[index]['name']),
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
                  itemCount: _tabArr2[index]['children'].length,
                  itemBuilder: (BuildContext context, int indexc) {
                    Map itemFriend = _tabArr2[index]['children'][indexc];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(itemFriend['icon']),
                            ),
                            title: Text(itemFriend['remark'] != "" ? itemFriend['remark'] : itemFriend['name']),
                            subtitle: Text(
                              "[${itemFriend['isOnline'] == 1 ? '在线' : '离线'}] ${itemFriend['info']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Map talkobj = {
                                "objId": itemFriend['toId'],
                                "type": 1,
                              };
                              Navigator.pushNamed(
                                context,
                                '/friend-detail',
                                arguments: talkobj,
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
        itemCount: _tabArr3.length,
        itemBuilder: (BuildContext context, int index) {
          Map itemGroup = _tabArr3[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
            child: Column(children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(itemGroup['icon']),
                ),
                title: Text(itemGroup['remark'] != "" ? itemGroup['remark'] : itemGroup['name']),
                subtitle: Text(
                  itemGroup['info'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Map talkobj = {
                    "objId": itemGroup['toId'],
                    "type": 2,
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
