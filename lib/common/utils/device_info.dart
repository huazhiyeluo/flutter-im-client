library device_info_package;

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfo {
  final String deviceId;
  final String deviceName;

  DeviceInfo(this.deviceId, this.deviceName);

  static Future<DeviceInfo> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String deviceName = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = "${androidInfo.manufacturer}${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'Unknown';
        deviceName = iosInfo.name;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'Unknown';
        deviceName = macInfo.model;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'Unknown';
        deviceName = linuxInfo.name;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        deviceName = windowsInfo.computerName;
      } else if (kIsWeb) {
        WebBrowserInfo websInfo = await deviceInfo.webBrowserInfo;
        deviceId = websInfo.platform!;
        deviceName = websInfo.userAgent!;
      }
    } catch (e) {
      deviceId = 'Error: $e';
      deviceName = 'Error: $e';
    }

    return DeviceInfo(deviceId, deviceName);
  }

  static Future<int> getPlatformType() async {
    if (Platform.isAndroid) {
      return 2;
    } else if (Platform.isIOS) {
      return 1;
    } else {
      return 0;
    }
  }
}
