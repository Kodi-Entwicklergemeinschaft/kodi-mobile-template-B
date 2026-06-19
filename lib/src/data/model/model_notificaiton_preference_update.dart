import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_notificaiton_preference_update.freezed.dart';
part 'model_notificaiton_preference_update.g.dart';

@freezed
class ModelNotificationPreferenceUpdateRequest
    with _$ModelNotificationPreferenceUpdateRequest {
  factory ModelNotificationPreferenceUpdateRequest({
    String? type,
    int? id,
    bool? enabled,
  }) = _ModelNotificationPreferenceUpdateRequest;

  factory ModelNotificationPreferenceUpdateRequest.fromJson(
          Map<String, dynamic> json) =>
      _$ModelNotificationPreferenceUpdateRequestFromJson(json);
}
