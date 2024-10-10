class Apis {
  /// url 前缀
  // static const String apiPrefix = 'http://192.168.4.212:8081';
  // static const String socketUrl = 'ws://192.168.4.212:8081/chat';

  // static const String apiPrefix = 'http://im-siyuwen.com/api';
  // static const String socketUrl = 'ws://im-siyuwen.com/chat';

  static const String apiPrefix = 'https://im.siyuwen.com/api';
  static const String socketUrl = 'wss://im.siyuwen.com/chat';

  //login
  static const String login = '/user/login';

  //register
  static const String register = '/user/register';
  static const String bind = '/user/bind';

  //user
  static const String getOneUser = '/user/getOneUser';
  static const String actUser = '/user/actUser';
  static const String searchUser = '/user/searchUser';
  static const String actDeviceToken = '/user/actDeviceToken';

  //group
  static const String getOneGroup = '/user/getOneGroup';
  static const String createGroup = '/user/createGroup';
  static const String actGroup = '/user/actGroup';
  static const String searchGroup = '/user/searchGroup';

  //contact_friend
  static const String getContactFriendGroup = '/user/getContactFriendGroup';
  static const String editContactFriendGroup = '/user/editContactFriendGroup';
  static const String delContactFriendGroup = '/user/delContactFriendGroup';
  static const String sortContactFriendGroup = '/user/sortContactFriendGroup';

  static const String getContactFriendList = '/user/getContactFriendList';
  static const String getContactFriendOne = '/user/getContactFriendOne';
  static const String addContactFriend = '/user/addContactFriend';
  static const String inviteContactFriend = '/user/inviteContactFriend';
  static const String delContactFriend = '/user/delContactFriend';
  static const String actContactFriend = '/user/actContactFriend';

  // contact_group
  static const String getContactGroupList = '/user/getContactGroupList';
  static const String getContactGroupOne = '/user/getContactGroupOne';
  static const String getContactGroupUser = '/user/getContactGroupUser';
  static const String joinContactGroup = '/user/joinContactGroup';
  static const String delContactGroup = '/user/delContactGroup';
  static const String quitContactGroup = '/user/quitContactGroup';
  static const String actContactGroup = '/user/actContactGroup';

  // apply
  static const String getApplyList = '/user/getApplyList';
  static const String operateApply = '/user/operateApply';

  static const String upload = '/attach/upload';
}
