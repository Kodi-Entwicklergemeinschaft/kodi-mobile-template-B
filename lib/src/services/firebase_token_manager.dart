import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:loggy/loggy.dart';
import 'package:uuid/uuid.dart';

class FirebaseTokenManager {

  Future<void> fetchAndUploadToken() async {
    int uId = await _getLoggedUserId();
    bool isTokenRegistered = await _isFcmTokenRegistered();
    if (uId > 0 && !isTokenRegistered) {
      String? token = await FirebaseMessaging.instance.getToken();
      logInfo("FCM token : $token");
      if (token != null) _uploadToken(uId, token);
    } 
  }

  Future<void> uploadRefreshToken(refreshToken) async {
    logInfo("FCM token refresh: $refreshToken");
    await _udpateFcmTokenRegistrationStatus(false);
    int uId = await _getLoggedUserId();
    bool isTokenRegistered = await _isFcmTokenRegistered();
    if (uId > 0 && !isTokenRegistered) {
      _uploadToken(uId, refreshToken);
    }
  }

  Future<void> _uploadToken(int userId, String token) async {
    final deviceId = await _getDeviceId();
    final response = await Api.uploadToken(
        userId, {"token": token, "deviceId": deviceId});
    if (response.success) {
      await _udpateFcmTokenRegistrationStatus(true);
    }
    logInfo("FCM token upload success: ${response.success}");
    logInfo("FCM token: $token");
  }

  Future<String?> _getDeviceId() async {
    final savedDeviceId = await _getSavedDeviceId();
    if (savedDeviceId.isNotEmpty == true) {
      return savedDeviceId;
    }
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
    deviceId ??= const Uuid().v4();
    await _saveDeviceId(deviceId);
    return deviceId;
  }

  Future<int> _getLoggedUserId() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    return userId;
  }

  Future<String> _getSavedDeviceId() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.deviceId, "");
    return userId;
  }

  Future<void> _saveDeviceId(deviceId) async {
    final prefs = await Preferences.openBox();
    prefs.setKeyValue(Preferences.deviceId, deviceId);
  }

  Future<bool> _isFcmTokenRegistered() async {
    final prefs = await Preferences.openBox();
    final userId =
        prefs.getKeyValue(Preferences.tokenRegistrationStatus, false);
    return userId;
  }

  Future<void> _udpateFcmTokenRegistrationStatus(status) async {
    final prefs = await Preferences.openBox();
    prefs.setKeyValue(Preferences.tokenRegistrationStatus, status);
  }


 
}