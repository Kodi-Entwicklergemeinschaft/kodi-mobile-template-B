// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_notification_preferences.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/account/account_profile/cubit/account_cubit.dart';
import 'package:your_app_name/src/presentation/main/account/notification_settings/notification_settings_cubit.dart';
import 'package:your_app_name/src/presentation/main/account/notification_settings/notification_settngs_state.dart';
import 'package:your_app_name/src/presentation/widget/app_list_title.dart';
import 'package:your_app_name/src/utils/configs/language.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettingsCubit _notifiationCubit;
  NotificaitonPreferencesModel? _notificationPreference;

  @override
  void initState() {
    _notifiationCubit = BlocProvider.of<NotificationSettingsCubit>(context)
      ..fetchNotificationPreference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('notification'),
        ),
      ),
      body: SafeArea(
        child:
            BlocConsumer<NotificationSettingsCubit, NotificationSettingsState>(
          listener: (context, state) {
            state.maybeWhen(
                loaded: (preferences) {
                  setState(() {
                    _notificationPreference = preferences;
                  });
                },
                updateError: (random) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(Translate.of(context)
                            .translate('notification_update_error'))),
                  );
                },
                orElse: () {});
          },
          builder: (blocContext, state) {
            if (state is NotificationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationSettingsFetchError ||
                (_notificationPreference == null)) {
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                          textAlign: TextAlign.center,
                          Translate.of(context)
                              .translate('notification_fetch_error'))));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppListTitle(
                    title: Translate.of(context).translate('all_notification'),
                    trailing: CupertinoSwitch(
                      activeColor: Theme.of(blocContext).primaryColor,
                      value: _notificationPreference?.enabled ?? false,
                      onChanged: (value) async {
                        _notifiationCubit
                            .updateAllNotificationPreference(value);
                      },
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        _notificationPreference?.preferences?.length ?? 0,
                    itemBuilder: (context, index) {
                      final preferenceCategory =
                          _notificationPreference!.preferences![index];
                      return AppListTitle(
                        title: preferenceCategory.name ?? "",
                        onPressed: () {
                          if (_notificationPreference?.enabled == true) {
                            if (preferenceCategory.type ==
                                    "CATEGORY_PREFERENCE" &&
                                _isNoCitySelected()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(Translate.of(context).translate(
                                      'notificaiton_error_no_city_selected'))),
                            );
                            } else {
                              _showNotificationOptions(
                                  blocContext, preferenceCategory, index);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(Translate.of(context).translate(
                                      'notification_disabled_state_error'))),
                            );
                          }
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
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNotificationOptions(
      BuildContext blocContext, PreferenceCategory category, int index) {
    showDialog(
      context: blocContext,
      builder: (context) {
        return NotificationOptionsDialog(
          category: category,
          index: index,
        );
      },
    );
  }

  bool _isNoCitySelected() {
    final preferenceList = _notificationPreference?.preferences;
    if (preferenceList == null || preferenceList.isEmpty) {
      return true;
    }
    for (PreferenceCategory preference in preferenceList) {
      if (preference.type == "CITY_PREFERENCE") {
        final cityPreferencelist = preference.preferences;
        if (cityPreferencelist == null || cityPreferencelist.isEmpty) {
          return true;
        }
        for (PreferenceItem preferenceItem in cityPreferencelist) {
          if (preferenceItem.enabled == true) {
            return false;
          }
        }
      }
    }
    return true;
  }
}

class NotificationOptionsDialog extends StatefulWidget {
  final PreferenceCategory category;
  final int index;

  const NotificationOptionsDialog({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  _NotificationOptionsDialogState createState() =>
      _NotificationOptionsDialogState();
}

class _NotificationOptionsDialogState extends State<NotificationOptionsDialog> {
  late PreferenceCategory updatedCategory;
  late NotificationSettingsCubit _notificationSettingsCubit;

  @override
  void initState() {
    super.initState();
    _notificationSettingsCubit =
        BlocProvider.of<NotificationSettingsCubit>(context);
    updatedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      actionsPadding: const EdgeInsets.all(10),
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(updatedCategory.name ?? ""),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ScaffoldMessenger(
          child: Builder(builder: (scaffoldContext) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: BlocConsumer<NotificationSettingsCubit,
                  NotificationSettingsState>(
                listener: (context, state) {
                  state.maybeWhen(
                      updateError: (random) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                              content: Text(Translate.of(context)
                                  .translate('notification_update_error'))),
                        );
                      },
                      orElse: () {});
                },
                builder: (context, state) {
                  if (state is NotificationSettingsAllCategoryUpdate) {
                    _updateAllListItems(state.enabled);
                  } else if (state is UpdateVisibleCategoryItem) {
                    _updateListItemView(state.index, state.value);
                  }

                  return SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppListTitle(
                            title: Translate.of(context).translate('all'),
                            trailing: CupertinoSwitch(
                              activeColor: Theme.of(context).primaryColor,
                              value: _geIsCategoryEnabled(),
                              onChanged: (value) async {
                                _notificationSettingsCubit
                                    .updateCategoryAllNotificationPreference(
                                        updatedCategory.type, value);
                              },
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: updatedCategory.preferences?.length ?? 0,
                            itemBuilder: (context, index) {
                              final categoryItem =
                                  updatedCategory.preferences![index];
                              return AppListTitle(
                                title: categoryItem.name ?? "",
                                trailing: CupertinoSwitch(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: categoryItem.enabled ?? false,
                                  onChanged: (value) async {
                                    _notificationSettingsCubit
                                        .updateCategoryNotificationPreference(
                                            updatedCategory.type,
                                            categoryItem.id,
                                            value,
                                            index);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Translate.of(context).translate('close')),
        ),
      ],
    );
  }

  void _updateListItemView(int index, bool value) {
    updatedCategory = updatedCategory.copyWith(
      preferences: [
        for (int i = 0; i < (updatedCategory.preferences?.length ?? 0); i++)
          i == index
              ? updatedCategory.preferences![i].copyWith(
                  enabled: value,
                )
              : updatedCategory.preferences![i],
      ],
    );
  }

  bool _geIsCategoryEnabled() {
    if (updatedCategory.preferences == null || updatedCategory.preferences!.isEmpty) {
      return false;
    }

    // All items must be enabled to consider the category enabled
    for (final item in updatedCategory.preferences!) {
      if (item.enabled != true) {
        return false;
      }
    }
    return true;
  }


  void _updateAllListItems(bool enabled) {
    updatedCategory = updatedCategory.copyWith(
      preferences: [
        for (int i = 0; i < (updatedCategory.preferences?.length ?? 0); i++)
          updatedCategory.preferences![i].copyWith(
            enabled: enabled,
          )
      ],
    );
  }
}
