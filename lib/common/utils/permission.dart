import 'package:permission_handler/permission_handler.dart';

/// 权限工具类
class PermissionUtil {
  /// 申请摄像头权限
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 申请存储权限
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }
}
