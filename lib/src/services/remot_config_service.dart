import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;
  Map<String, dynamic> config = {};

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setDefaults(const {
      'app_config': '{}',
    });

    try {
      await _remoteConfig.fetchAndActivate();
      final jsonString = _remoteConfig.getString('remote_urls');
      config = json.decode(jsonString);
    } catch (e) {
      print('Remote Config fetch failed: $e');
    }
  }

  String getBaseUrl({bool forum = false}) {
    final urls = config['baseUrls'] ?? {};
    return forum ? urls['forum'] : urls['default'];
  }

  String get wsUrl => config['wsUrl'] ?? '';
  String get picturesURL => config['picturesURL'] ?? '';
  String get defaultPicturesURL => config['defaultPicturesURL'] ?? '';
}
