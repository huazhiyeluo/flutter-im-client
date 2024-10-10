import 'package:qim/common/utils/db.dart';

Future<void> initialDb(int uid) async {
  // Define the database name and table SQLs
  String dbName = 'qim-$uid.db';

  // List of SQL commands to create tables
  List<String> tableSQLs = [
    'CREATE TABLE IF NOT EXISTS `user` ('
        'uid INTEGER PRIMARY KEY, '
        'nickname TEXT, '
        'email TEXT, '
        'phone TEXT, '
        'avatar TEXT, '
        'sex INTEGER, '
        'birthday INTEGER, '
        'info TEXT, '
        'exp INTEGER, '
        'createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `group` ('
        'groupId INTEGER PRIMARY KEY, '
        'ownerUid INTEGER, '
        'name TEXT, '
        'icon TEXT, '
        'info TEXT, '
        'num INTEGER, '
        'exp INTEGER, '
        'createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `apply` ('
        'id INTEGER PRIMARY KEY, '
        'fromId INTEGER, '
        'fromName TEXT, '
        'fromIcon TEXT, '
        'toId INTEGER, '
        'toName TEXT, '
        'toIcon TEXT, '
        'type INTEGER, '
        'status INTEGER, '
        'reason TEXT, '
        'operateTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `friend_group` ('
        'friendGroupId INTEGER PRIMARY KEY, '
        'name TEXT, '
        'ownerUid INTEGER, '
        'isDefault INTEGER, '
        'sort INTEGER)',
    'CREATE TABLE IF NOT EXISTS `contact_friend` ('
        'fromId INTEGER, '
        'toId INTEGER, '
        'friendGroupId INTEGER, '
        'level INTEGER, '
        'remark TEXT, '
        'desc TEXT, '
        'isTop INTEGER, '
        'isHidden INTEGER, '
        'isQuiet INTEGER, '
        'joinTime INTEGER, '
        'isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS `contact_group` ('
        'fromId INTEGER, '
        'toId INTEGER, '
        'groupPower INTEGER, '
        'level INTEGER, '
        'remark TEXT, '
        'nickname TEXT, '
        'isTop INTEGER, '
        'isHidden INTEGER, '
        'isQuiet INTEGER, '
        'joinTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `message` ('
        'id TEXT, '
        'fromId INTEGER, '
        'toId INTEGER, '
        'nickname TEXT, '
        'avatar TEXT, '
        'msgType INTEGER, '
        'msgMedia INTEGER, '
        'content TEXT, '
        'createTime INTEGER)',
    'CREATE INDEX index_id ON message (id);',
    'CREATE TABLE IF NOT EXISTS `chat` ('
        'id INTEGER PRIMARY KEY, '
        'objId INTEGER, '
        'type INTEGER, '
        'name TEXT, '
        'info TEXT, '
        'remark TEXT, '
        'icon TEXT, '
        'isTop INTEGER, '
        'isHidden INTEGER, '
        'isQuiet INTEGER, '
        'tips INTEGER, '
        'operateTime INTEGER, '
        'msgMedia INTEGER, '
        'content TEXT)',
    'CREATE TABLE IF NOT EXISTS `share` ('
        'id INTEGER PRIMARY KEY, '
        'objId INTEGER, '
        'type INTEGER, '
        'name TEXT, '
        'info TEXT, '
        'remark TEXT, '
        'icon TEXT, '
        'operateTime INTEGER)',
  ];

  // Initialize the database with the specified name and tables
  await DBHelper.initDatabase(dbName, tableSQLs);
}
