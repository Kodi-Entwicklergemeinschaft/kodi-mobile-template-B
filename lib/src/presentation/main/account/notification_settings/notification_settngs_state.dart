import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_app_name/src/data/model/model_notification_preferences.dart';

part 'notification_settngs_state.freezed.dart';

@freezed
class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState.initial() = NotificationSettingsInitial;

  const factory NotificationSettingsState.loading() = NotificationSettingsLoading;

  const factory NotificationSettingsState.updating() = NotificationSettingsUpdating;

    const factory NotificationSettingsState.allCategoryUpdate(bool enabled) = NotificationSettingsAllCategoryUpdate;

  const factory NotificationSettingsState.loaded(NotificaitonPreferencesModel preferences) =
      NotificationSettingsLoaded;

  const factory NotificationSettingsState.fetchError() = NotificationSettingsFetchError;

  const factory NotificationSettingsState.updateError(int nextInt) = NotificationSettingsUpdateError;

  const factory NotificationSettingsState.updateVisibleCategoryItem(int index, bool value) = UpdateVisibleCategoryItem;
}
