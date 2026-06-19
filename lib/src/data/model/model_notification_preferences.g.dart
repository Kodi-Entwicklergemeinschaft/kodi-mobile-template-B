// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PreferenceModelImpl _$$PreferenceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PreferenceModelImpl(
      enabled: json['enabled'] as bool?,
      preferences: (json['preferences'] as List<dynamic>?)
          ?.map((e) => PreferenceCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PreferenceModelImplToJson(
        _$PreferenceModelImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'preferences': instance.preferences,
    };

_$PreferenceCategoryImpl _$$PreferenceCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$PreferenceCategoryImpl(
      type: json['type'] as String?,
      name: json['name'] as String?,
      preferences: (json['preferences'] as List<dynamic>?)
          ?.map((e) => PreferenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PreferenceCategoryImplToJson(
        _$PreferenceCategoryImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'preferences': instance.preferences,
    };

_$PreferenceItemImpl _$$PreferenceItemImplFromJson(Map<String, dynamic> json) =>
    _$PreferenceItemImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$$PreferenceItemImplToJson(
        _$PreferenceItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enabled': instance.enabled,
    };
