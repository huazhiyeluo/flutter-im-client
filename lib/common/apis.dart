class Apis {
  /// url 前缀
  // static const String apiPrefix = 'http://139.196.98.139:8081';

  // static const String apiPrefix = 'http://im-siyuwen.com/api';
  // static const String socketUrl = 'ws://im-siyuwen.com/chat';

  static const String apiPrefix = 'https://im.siyuwen.com/api';
  static const String socketUrl = 'wss://im.siyuwen.com/chat';

  //login
  static const String login = '/user/login';

  //register
  static const String register = '/user/register';

  //user
  static const String editUser = '/user/editUser';
  static const String actUser = '/user/actUser';

  //group
  static const String editGroup = '/user/editGroup';
  static const String actGroup = '/user/actGroup';

  //contact_friend
  static const String getContactFriendGroup = '/user/getContactFriendGroup';
  static const String getContactFriendList = '/user/getContactFriendList';
  static const String getContactFriendOne = '/user/getContactFriendOne';
  static const String addContactFriend = '/user/addContactFriend';
  static const String delContactFriend = '/user/delContactFriend';
  static const String actContactFriend = '/user/actContactFriend';

  // contact_group
  static const String getContactGroupList = '/user/getContactGroupList';
  static const String getContactGroupOne = '/user/getContactGroupOne';
  static const String getContactGroupUser = '/user/getContactGroupUser';
  static const String joinContactGroup = '/user/joinContactGroup';
  static const String quitContactGroup = '/user/quitContactGroup';
  static const String actContactGroup = '/user/actContactGroup';

  // apply
  static const String getApplyList = '/user/getApplyList';
  static const String operateApply = '/user/operateApply';

  static const String upload = '/attach/upload';
}
