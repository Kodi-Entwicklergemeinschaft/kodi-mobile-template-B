import 'package:your_app_name/src/utils/configs/preferences.dart';

class UserDataUtil {
  static Future<void> cleanUserData() async {
    final prefs = await Preferences.openBox();
    prefs.deleteKey(Preferences.userId);
    prefs.deleteKey(Preferences.tokenRegistrationStatus);
    prefs.deleteKey(Preferences.refreshToken);
    prefs.deleteKey(Preferences.token);
  }

  static Future<int> getLoggedUserId() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    return userId;
  }

  static Future<bool> hasValidUserId() async {
    final userId = await getLoggedUserId();
    return userId > 0;
  }
}
