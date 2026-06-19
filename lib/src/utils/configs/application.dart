import 'package:your_app_name/src/data/model/model_device.dart';
import 'package:your_app_name/src/data/model/model_setting.dart';

import '../../services/remot_config_service.dart';
import 'package:your_app_name/src/data/model/model_device.dart';
import 'package:your_app_name/src/data/model/model_setting.dart';

class Application {
  static bool debug = true;
  static String domain = 'https://your-app-domain.com';
  static DeviceModel? device;
  static SettingModel setting = SettingModel.fromDefault();

  static String picturesURL = '';
  static String defaultPicturesURL = '';

  static final Application _instance = Application._internal();

  factory Application() => _instance;

  Application._internal();

  // ✅ Call this AFTER RemoteConfig is initialized
  void loadRemoteConfig(Map<String, dynamic> config) {
    final urls = config['baseUrls'] ?? {};
    picturesURL = config['picturesURL'] ?? '';
    defaultPicturesURL = config['defaultPicturesURL'] ?? '';
  }
}
