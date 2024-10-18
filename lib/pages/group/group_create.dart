import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;

  bool _isChecked = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  int _defaultSelect = 0;

  bool isButtonEnabled = true;

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    // 监听焦点变化事件
    _focusNode1.addListener(() {
      if (_focusNode1.hasFocus) {
        setState(() {
          _isFocusNode1 = true;
        });
      } else {
        setState(() {
          _isFocusNode1 = false;
        });
      }
    });

    _focusNode2.addListener(() {
      if (_focusNode2.hasFocus) {
        setState(() {
          _isFocusNode2 = true;
        });
      } else {
        setState(() {
          _isFocusNode2 = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _infoController.dispose();
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
                  child: Stack(children: [
                    CustomTextFieldMore(
                      focusNode: _focusNode1,
                      isFocused: _isFocusNode1,
                      controller: _nameController,
                      hintText: '填写群名称(2-15个字)',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      suffixIcon: _isFocusNode1 && _nameController.text.trim() != ""
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                              ),
                              onPressed: () {
                                _nameController.text = "";
                                setState(() {});
                              },
                            )
                          : const SizedBox.shrink(),
                      focusedColor: const Color.fromARGB(255, 60, 183, 21),
                      unfocusedColor: Colors.grey,
                      showUnderline: false,
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text(
                        "${_nameController.text.characters.length}/15字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.white,
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
                  child: Stack(
                    children: [
                      CustomTextFieldMore(
                        focusNode: _focusNode2,
                        isFocused: _isFocusNode2,
                        maxLines: 5,
                        controller: _infoController,
                        hintText: '填写群介绍(2-500个字)',
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        suffixIcon: _isFocusNode2 && _infoController.text.trim() != ""
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                                ),
                                onPressed: () {
                                  _infoController.text = "";
                                  setState(() {});
                                },
                              )
                            : const SizedBox.shrink(),
                        focusedColor: const Color.fromARGB(255, 60, 183, 21),
                        unfocusedColor: Colors.grey,
                        showUnderline: false,
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Text(
                          "${_infoController.text.characters.length}/500字",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
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
                crossAxisCount: 5,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ),
              itemCount: 10,
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
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
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
                isButtonEnabled ? _createGroup() : null;
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

  Widget _showAvatar(int index) {
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

  void _selectAvatar(index) {
    setState(() {
      _defaultSelect = index;
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
    if (!isButtonEnabled) return;
    setState(() {
      isButtonEnabled = false;
    });
    if (_nameController.text.trim() == "") {
      TipHelper.instance.showToast("请输入群名称");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }
    if (_infoController.text.trim() == "") {
      TipHelper.instance.showToast("请输入群介绍");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }

    if (_defaultSelect == 0) {
      if (_imageFile == null) {
        TipHelper.instance.showToast("请选择头像");
        setState(() {
          isButtonEnabled = true;
        });
        return;
      }
    }

    if (!_isChecked) {
      TipHelper.instance.showToast("请勾选同意条款");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }

    if (_defaultSelect == 0) {
      XFile compressedFile = await compressImage(_imageFile!);
      dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) async {
        var params = {
          'ownerUid': uid,
          'type': 0,
          'name': _nameController.text,
          'icon': res['data'],
          'info': _infoController.text,
        };
        _createGroupDo(params);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    } else {
      var params = {
        'ownerUid': uid,
        'type': 0,
        'name': _nameController.text,
        'icon': "https://img.siyuwen.com/godata/avatar/$_defaultSelect.jpg",
        'info': _infoController.text,
      };
      _createGroupDo(params);
    }
  }

  _createGroupDo(Map params) async {
    GroupApi.createGroup(params, onSuccess: (res) async {
      Map talkObj = {
        "objId": res['data']['groupId'],
        "type": ObjectTypes.group,
      };
      Navigator.pushNamed(
        context,
        '/group-chat-setting',
        arguments: talkObj,
      );
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      setState(() {
        isButtonEnabled = true;
      });
    });
  }
}
