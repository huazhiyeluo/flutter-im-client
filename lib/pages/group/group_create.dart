import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/common.dart';
import 'package:qim/data/api/group.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/permission.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:dio/dio.dart' as dio;

class GroupCreate extends StatefulWidget {
  const GroupCreate({super.key});

  @override
  State<GroupCreate> createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        title: const Text("创建群"),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "取消",
            style: TextStyle(
              color: AppColors.textButtonColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: const GroupCreatePage(),
    );
  }
}

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final UserInfoController userInfoController = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController infoController = TextEditingController();

  bool _isChecked = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  bool _isShowNameClear = false;
  bool _isShowInfoClear = false;

  int _defaultSelect = 0;

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.white, // 设置白色背景
            child: Row(
              textBaseline: TextBaseline.alphabetic,
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    '群名称',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    onChanged: (val) {
                      _checkName(val);
                    },
                    decoration: InputDecoration(
                      suffixIcon: _isShowNameClear
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color.fromARGB(199, 171, 175, 169),
                              ),
                              onPressed: _clearName,
                            )
                          : const SizedBox.shrink(),
                      hintText: '填写群名称(2-32个字)',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.white, // 设置白色背景
            child: Row(
              textBaseline: TextBaseline.alphabetic,
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    '群介绍',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLines: 5,
                    controller: infoController,
                    keyboardType: TextInputType.text,
                    onChanged: (val) {
                      _checkInfo(val);
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      suffixIcon: _isShowInfoClear
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color.fromARGB(199, 171, 175, 169),
                              ),
                              onPressed: _clearInfo,
                            )
                          : const SizedBox.shrink(),
                      hintText: '填写群介绍(2-500个字)',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.white, // 设置白色背景
            child: const Text(
              "群头像",
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            height: 185, // 设置 GridView 的固定高度
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 每行显示5个
                crossAxisSpacing: 20.0, // 每个头像之间的水平间距
                mainAxisSpacing: 20.0, // 每个头像之间的垂直间距
              ),
              itemCount: 10, // 总共10个头像（包括加号按钮）
              itemBuilder: (context, index) {
                return _showAvatar(index);
              },
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: _isChecked,
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value!;
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            controlAffinity: ListTileControlAffinity.leading, // 勾选框在前面
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0), // 紧凑显示
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '已阅读并同意 '),
                  TextSpan(
                    text: '《服务声明》',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(
                          '/term',
                          arguments: {"title": "服务声明", "htmlFilePath": "lib/assets/term/group_term.html"},
                        );
                      },
                  ),
                  const TextSpan(text: '。根据主管部门要求，未成年人禁止担任粉丝群的群主/管理员，一经核实将按照相关规则进行处理。'),
                ],
              ),
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () {
                _createGroup();
              },
              text: "立即创建",
              backgroundColor: const Color.fromARGB(255, 60, 183, 21),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "理性追星不盲从，文明表达互尊重,\n违法违规立举报，社群公约共遵守",
            style: TextStyle(fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _showAvatar(int index) {
    if (index == 0) {
      // 加号按钮
      return GestureDetector(
        onTap: () {
          _uploadAvatar();
        },
        child: _imageFile == null
            ? Icon(
                Icons.add,
                size: 60,
                color: Colors.grey[300],
              )
            : index == _defaultSelect
                ? Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(_imageFile!.path),
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_imageFile!.path),
                  ),
      );
    } else {
      return index == _defaultSelect
          ? GestureDetector(
              onTap: () {
                _selectAvatar(index);
              },
              child: Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider("http://img.siyuwen.com/godata/avatar/$index.jpg"),
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                _selectAvatar(index);
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider("http://img.siyuwen.com/godata/avatar/$index.jpg"),
              ),
            );
    }
  }

  _selectAvatar(index) {
    setState(() {
      _defaultSelect = index;
    });
  }

  _checkName(val) {
    if (val != "") {
      setState(() {
        _isShowNameClear = true;
      });
    } else {
      setState(() {
        _isShowNameClear = false;
      });
    }
  }

  _clearName() {
    nameController.text = "";
    setState(() {
      _isShowNameClear = false;
    });
  }

  _checkInfo(val) {
    if (val != "") {
      setState(() {
        _isShowInfoClear = true;
      });
    } else {
      setState(() {
        _isShowInfoClear = false;
      });
    }
  }

  _clearInfo() {
    infoController.text = "";
    setState(() {
      _isShowInfoClear = false;
    });
  }

  Future<void> _uploadAvatar() async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _defaultSelect = 0;
      });
    }
  }

  _createGroup() async {
    if (!_isChecked) {
      TipHelper.instance.showToast("请勾选同意条款");
      return;
    }

    if (_defaultSelect == 0) {
      if (_imageFile == null) {
        TipHelper.instance.showToast("请选择头像");
        return;
      }
      XFile compressedFile = await compressImage(_imageFile!);
      dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) async {
        var params = {'ownerUid': uid, 'type': 0, 'name': nameController.text, 'icon': res['data'], 'info': infoController.text};
        _createGroupDo(params);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    } else {
      var params = {'ownerUid': uid, 'type': 0, 'name': nameController.text, 'icon': "http://img.siyuwen.com/godata/avatar/$_defaultSelect.jpg", 'info': infoController.text};
      _createGroupDo(params);
    }
  }

  _createGroupDo(Map params) async {
    GroupApi.createGroup(params, onSuccess: (res) async {
      Map talkObj = {
        "objId": res['data']['groupId'],
        "type": 2,
      };
      Navigator.pushNamed(
        context,
        '/group-chat-setting',
        arguments: talkObj,
      );
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
