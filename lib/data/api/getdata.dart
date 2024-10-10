import 'dart:async';

import 'package:qim/data/api/group.dart';
import 'package:qim/data/api/user.dart';

Future<Map> getApiOneUser(int uid) async {
  Completer<Map> completer = Completer<Map>();
  UserApi.getOneUser({"uid": uid}, onSuccess: (res) {
    completer.complete(res['data']);
  }, onError: (res) {
    completer.complete({});
  });
  return completer.future;
}

Future<Map> getApiOneGroup(int groupId) async {
  Completer<Map> completer = Completer<Map>();
  GroupApi.getOneGroup({"groupId": groupId}, onSuccess: (res) {
    completer.complete(res['data']);
  }, onError: (res) {
    completer.complete({});
  });
  return completer.future;
}
