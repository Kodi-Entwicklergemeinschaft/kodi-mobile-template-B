// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:your_app_name/main_dev.dart';
import 'package:your_app_name/src/services/firebase_messaging_service.dart';
import 'package:your_app_name/src/utils/user_data_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_user.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/widget/app_list_title.dart';
import 'package:your_app_name/src/utils/configs/language.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/configs/theme.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.user});

  final UserModel? user;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late final Preferences prefs;
  late final String pushNotificationsPermission;
  late bool _receiveNotification = true;
  bool darkModeEnabled = true;
  bool _isLoggedInUser = false;

  Future<void> initializePreferences() async {
    final prefs = await Preferences.openBox();
    final pushNotificationsPermission =
        await prefs.getKeyValue(Preferences.pushNotificationsPermission, '0');
    final receiveNotification =
        await prefs.getKeyValue(Preferences.receiveNotification, '0');
    final isLoggedInUser = await UserDataUtil.hasValidUserId();

    setState(() {
      if (pushNotificationsPermission == "authorized" &&
          receiveNotification == "true") {
        _receiveNotification = true;
      } else if (pushNotificationsPermission == "authorized" &&
          receiveNotification == "false") {
        _receiveNotification = false;
      } else if (pushNotificationsPermission == "denied") {
        _receiveNotification = false;
      }
      _isLoggedInUser = isLoggedInUser;
    });
  }

  Future<void> updateNotificationPermissionPreference(bool newValue) async {
    setState(() {
      _receiveNotification = newValue;
    });

    final prefs = await Preferences.openBox();
    final pushNotificationsPermission = await prefs.getKeyValue(
        Preferences.pushNotificationsPermission, 'notAsked');

    if (pushNotificationsPermission == 'denied') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              Translate.of(context).translate('enableNotification'),
            ),
            content: Text(
              Translate.of(context).translate('notificationPermission'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  Translate.of(context).translate('cancel'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  Translate.of(context).translate('openSettings'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Perform the background operation
      await prefs.setKeyValue(
          Preferences.receiveNotification, newValue ? 'true' : 'false');
      await FirebaseMessagingService(globalNavKey, prefs)
          .refreshNotifications();
    }
  }

  Future<void> openAppSettings() async {
    if (!await launchUrl(Uri.parse('app-settings:'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to open app settings.'),
      ));
    }
  }

  Future<String> getAppVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<void> checkNotificationPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final prefs = await Preferences.openBox();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await prefs.setKeyValue(
          Preferences.pushNotificationsPermission, 'authorized');
      setState(() {
        _receiveNotification = true;
      });
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await prefs.setKeyValue(
          Preferences.pushNotificationsPermission, 'denied');
      setState(() {
        _receiveNotification = false;
      });
    }
  }

  Future<void> switchTheme() async {
    final prefBox = await Preferences.openBox();

    DarkOption darkOption =
        darkModeEnabled ? DarkOption.alwaysOn : DarkOption.alwaysOff;
    String darkOptionValue = darkModeEnabled ? 'on' : 'off';

    await prefBox.setKeyValue(Preferences.darkOption, darkOptionValue);
    AppBloc.themeCubit.onChangeTheme(darkOption: darkOption);
  }

  Future<void> isDarkMode() async {
    final prefBox = await Preferences.openBox();
    String darkMode = await prefBox.getKeyValue(Preferences.darkOption, 'on');
    setState(() {
      darkModeEnabled = (darkMode == 'on');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isDarkMode();
    initializePreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      checkNotificationPermissionStatus();
    }
  }

  void _onNavigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('setting'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: <Widget>[
            if (_isLoggedInUser)
              _getManagerNotificationWidget()
            else
              AppListTitle(
                title: Translate.of(context).translate('notification'),
                trailing: CupertinoSwitch(
                  activeColor: Theme.of(context).primaryColor,
                  value: _receiveNotification,
                  onChanged: (value) async {
                    await updateNotificationPermissionPreference(value);
                  },
                ),
              ),
            AppListTitle(
              title: "Dark Mode",
              trailing: CupertinoSwitch(
                activeColor: Theme.of(context).primaryColor,
                value: darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    darkModeEnabled = value;
                    switchTheme();
                  });
                },
              ),
            ),
            if (widget.user != null)
              AppListTitle(
                title: Translate.of(context).translate('profile_settings'),
                onPressed: () {
                  _onNavigate(Routes.profileSettings);
                },
                trailing: Row(
                  children: <Widget>[
                    RotatedBox(
                      quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
            AppListTitle(
              title: Translate.of(context).translate('legal'),
              onPressed: () {
                _onNavigate(Routes.legal);
              },
              trailing: Row(
                children: <Widget>[
                  RotatedBox(
                    quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
            AppListTitle(
              title: Translate.of(context).translate('version'),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Ensures space between items
                children: <Widget>[
                  FutureBuilder<String>(
                    future:
                        getAppVersion(), // This needs to be your method to get the app version
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!, // Display the version number
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getManagerNotificationWidget() {
    return Column(
      children: [
        AppListTitle(
          title: Translate.of(context).translate('notification'),
          onPressed: () => {
            setState(() {
              _showNotificationSettingsScreen();
            })
          },
          trailing: Row(
            children: <Widget>[
              RotatedBox(
                quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                child: const Icon(
                  Icons.keyboard_arrow_right,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationSettingsScreen() {
     _onNavigate(Routes.notificationSettings);
  }
}
