import 'package:flutter/material.dart';

/// 应用相关的常量
class AppConstants {
  static const String appName = "QIM";
}

/// 颜色相关的常量
class AppColors {
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color systemNavigationBarColor = Color.fromARGB(255, 255, 255, 255);
  static const Color appBackgroundColor = Color.fromARGB(255, 237, 237, 237);
  static const Color bottomBackgroundColor = Color.fromARGB(255, 247, 247, 247);
  static const Color textButtonColor = Color.fromARGB(255, 20, 20, 20);
}

// 对象类型
class ObjectTypes {
  static const int user = 1; // 个人
  static const int group = 2; // 群
}

// 对象类型
class ShareTypes {
  static const int single = 1; // 简单
  static const int complex = 2; //复杂
}

// 群对象类型
class GroupPowers {
  static const int normal = 1; // 普通用户
  static const int admin = 2; // 管理员
  static const int owner = 3; // 群主
}

// 消息类型
class AppWebsocket {
  // type 消息类型
  static const int msgTypeHeart = 0; // 心跳消息
  static const int msgTypeSingle = 1; // 单聊消息
  static const int msgTypeRoom = 2; // 群聊消息
  static const int msgTypeNotice = 3; // 通知消息
  static const int msgTypeAck = 4; // 应答消息
  static const int msgTypeBroadcast = 5; // 广播消息

  // media（type 1|2） 消息展示样式
  static const int msgMediaText = 1; // 文本
  static const int msgMediaImage = 2; // 图片
  static const int msgMediaAudio = 3; // 音频
  static const int msgMediaVideo = 4; // 视频
  static const int msgMediaFile = 5; // 文件
  static const int msgMediaEmoji = 6; // 表情
  static const int msgMediaNotOnline = 10; // 不在线
  static const int msgMediaNoConnect = 11; // 未接通
  static const int msgMediaTimes = 12; // 通话时长
  static const int msgMediaOff = 13; // 挂断电话
  static const int msgMediaInvite = 21; // 邀请入群消息
  static const int msgMediaUser = 22; // 个人名片消息
  static const int msgMediaGroup = 23; // 群名片消息

  // media（type 3） 消息展示样式
  static const int msgMediaOfflinePack = 10; // 挤下线
  static const int msgMediaOnline = 11; // 上线
  static const int msgMediaOffline = 12; // 下线
  static const int msgMediaUserinfo = 13; // 用户信息
  static const int msgMediaGroupinfo = 14; // 群信息

  static const int msgMediaFriendAdd = 21; // 添加好友
  static const int msgMediaFriendAgree = 22; // 成功添加好友
  static const int msgMediaFriendRefuse = 23; // 拒绝添加好友
  static const int msgMediaFriendDelete = 24; // 删除好友

  static const int msgMediaGroupCreate = 30; // 创建群
  static const int msgMediaGroupJoin = 31; // 添加群
  static const int msgMediaGroupAgree = 32; // 成功添加群
  static const int msgMediaGroupRefuse = 33; // 拒绝添加群
  static const int msgMediaGroupDelete = 34; // 退出群
  static const int msgMediaGroupDisband = 35; // 解散群
  static const int msgMediaContactGroupUpdate = 36; // 群联系人更新

  // media（type 4） 消息展示样式
  static const int msgMediaPhoneOffer = 1; // 发起聊天 | offer
  static const int msgMediaPhoneAnswer = 2; // 接通聊天 | answer
  static const int msgMediaPhoneIce = 3; // ICE候选
  static const int msgMediaPhoneQuit = 4; // 退出聊天
}
