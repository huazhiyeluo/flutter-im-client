class Apis {
  /// url 前缀
  // static const String apiPrefix = 'http://139.196.98.139:8081';

  static const String apiPrefix = 'http://im-siyuwen.com/api';
  static const String socketUrl = 'ws://im-siyuwen.com/chat';

  // static const String apiPrefix = 'https://im.siyuwen.com/api';
  // static const String socketUrl = 'wss://im.siyuwen.com/chat';

  static const String login = '/user/login';
  static const String register = '/user/register';

  static const String getContactFriendGroup = '/user/getContactFriendGroup';
  static const String getContactFriendList = '/user/getContactFriendList';
  static const String getContactFriendOne = '/user/getContactFriendOne';

  static const String getContactGroupList = '/user/getContactGroupList';
  static const String getContactGroupOne = '/user/getContactGroupOne';
  static const String getContactGroupUser = '/user/getContactGroupUser';

  static const String actContactFriend = '/user/actContactFriend';
  static const String actContactGroup = '/user/actContactGroup';

  static const String getApplyList = '/user/getApplyList';

  static const String upload = '/attach/upload';
}
