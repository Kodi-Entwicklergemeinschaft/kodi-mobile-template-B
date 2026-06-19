import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/presentation/main/account/notification_settings/notification_settngs_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final UserRepository _userRepository = UserRepository();

  NotificationSettingsCubit() : super(const NotificationSettingsInitial());

  Future<void> fetchNotificationPreference() async {
    emit(const NotificationSettingsLoading());
    try {
      final result = await _userRepository.getNotificationPreferences();
      if (result != null) {
        emit(NotificationSettingsLoaded(result));
      } else {
        emit(const NotificationSettingsFetchError());
      }
    } catch (e) {
      emit(const NotificationSettingsFetchError());
    }
  }

  Future<void> updateCategoryNotificationPreference(
    String? type,
    int? id,
    bool enabled,
    int index,
  ) async {
    emit(UpdateVisibleCategoryItem(index, enabled));
    try {
      final result =
          await UserRepository.updateNotificationPreferences(type, id, enabled);
      if (result != null && result) {
        await fetchNotificationPreferenceInBackground();
      } else {
        emit(NotificationSettingsUpdateError(Random().nextInt(1000)));
        await Future.delayed(const Duration(milliseconds: 10));
        emit(UpdateVisibleCategoryItem(index, !enabled));
      }
    } catch (e) {
      emit(NotificationSettingsUpdateError(Random().nextInt(1000)));
    }
  }

  Future<void> updateCategoryAllNotificationPreference(
    String? type,
    bool enabled,
  ) async {
    emit(NotificationSettingsAllCategoryUpdate(enabled));
    try {
      final result = await UserRepository.updateNotificationPreferences(
          type, null, enabled);
      if (result != null && result) {
        await fetchNotificationPreferenceInBackground();
      } else {
        emit(NotificationSettingsUpdateError(Random().nextInt(1000)));
        await Future.delayed(const Duration(milliseconds: 10));
        emit(NotificationSettingsAllCategoryUpdate(!enabled));
      }
    } catch (e) {
      emit(NotificationSettingsUpdateError(Random().nextInt(1000)));
    }
  }

  Future<void> fetchNotificationPreferenceInBackground() async {
    try {
      final result = await _userRepository.getNotificationPreferences();
      if (result != null) {
        emit(NotificationSettingsLoaded(result));
      }
    } catch (e) {}
  }

  Future<void> updateAllNotificationPreference(bool value) async {
    emit(const NotificationSettingsLoading());
    try {
      final result =
          await UserRepository.updateNotificationPreferences(null, null, value);
      if (result != null && result) {
        await fetchNotificationPreference();
      } else {
        emit(NotificationSettingsUpdateError(Random().nextInt(1000)));
      }
    } catch (e) {
      emit(const NotificationSettingsFetchError());
    }
  }
}
