import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_notification_preferences.freezed.dart';
part 'model_notification_preferences.g.dart';

@freezed
class NotificaitonPreferencesModel with _$NotificaitonPreferencesModel {
  factory NotificaitonPreferencesModel({
    bool? enabled,
    List<PreferenceCategory>? preferences,
  }) = _PreferenceModel;

  factory NotificaitonPreferencesModel.fromJson(Map<String, dynamic> json) => _$NotificaitonPreferencesModelFromJson(json);
}

@freezed
class PreferenceCategory with _$PreferenceCategory {
  factory PreferenceCategory({
    String? type,
    String? name,
    List<PreferenceItem>? preferences,
  }) = _PreferenceCategory;

  factory PreferenceCategory.fromJson(Map<String, dynamic> json) => _$PreferenceCategoryFromJson(json);
}

@freezed
class PreferenceItem with _$PreferenceItem {
  factory PreferenceItem({
    int? id,
    String? name,
    bool? enabled,
  }) = _PreferenceItem;

  factory PreferenceItem.fromJson(Map<String, dynamic> json) => _$PreferenceItemFromJson(json);
}
