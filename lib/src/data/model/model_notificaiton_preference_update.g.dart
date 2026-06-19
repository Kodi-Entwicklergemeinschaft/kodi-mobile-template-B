// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_notificaiton_preference_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModelNotificationPreferenceUpdateRequestImpl
    _$$ModelNotificationPreferenceUpdateRequestImplFromJson(
            Map<String, dynamic> json) =>
        _$ModelNotificationPreferenceUpdateRequestImpl(
          type: json['type'] as String?,
          id: (json['id'] as num?)?.toInt(),
          enabled: json['enabled'] as bool?,
        );

Map<String, dynamic> _$$ModelNotificationPreferenceUpdateRequestImplToJson(
        _$ModelNotificationPreferenceUpdateRequestImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'enabled': instance.enabled,
    };
