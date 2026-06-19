// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_notificaiton_preference_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModelNotificationPreferenceUpdateRequest
    _$ModelNotificationPreferenceUpdateRequestFromJson(
        Map<String, dynamic> json) {
  return _ModelNotificationPreferenceUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ModelNotificationPreferenceUpdateRequest {
  String? get type => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  bool? get enabled => throw _privateConstructorUsedError;

  /// Serializes this ModelNotificationPreferenceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelNotificationPreferenceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelNotificationPreferenceUpdateRequestCopyWith<
          ModelNotificationPreferenceUpdateRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelNotificationPreferenceUpdateRequestCopyWith<$Res> {
  factory $ModelNotificationPreferenceUpdateRequestCopyWith(
          ModelNotificationPreferenceUpdateRequest value,
          $Res Function(ModelNotificationPreferenceUpdateRequest) then) =
      _$ModelNotificationPreferenceUpdateRequestCopyWithImpl<$Res,
          ModelNotificationPreferenceUpdateRequest>;
  @useResult
  $Res call({String? type, int? id, bool? enabled});
}

/// @nodoc
class _$ModelNotificationPreferenceUpdateRequestCopyWithImpl<$Res,
        $Val extends ModelNotificationPreferenceUpdateRequest>
    implements $ModelNotificationPreferenceUpdateRequestCopyWith<$Res> {
  _$ModelNotificationPreferenceUpdateRequestCopyWithImpl(
      this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelNotificationPreferenceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? id = freezed,
    Object? enabled = freezed,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelNotificationPreferenceUpdateRequestImplCopyWith<$Res>
    implements $ModelNotificationPreferenceUpdateRequestCopyWith<$Res> {
  factory _$$ModelNotificationPreferenceUpdateRequestImplCopyWith(
          _$ModelNotificationPreferenceUpdateRequestImpl value,
          $Res Function(_$ModelNotificationPreferenceUpdateRequestImpl) then) =
      __$$ModelNotificationPreferenceUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? type, int? id, bool? enabled});
}

/// @nodoc
class __$$ModelNotificationPreferenceUpdateRequestImplCopyWithImpl<$Res>
    extends _$ModelNotificationPreferenceUpdateRequestCopyWithImpl<$Res,
        _$ModelNotificationPreferenceUpdateRequestImpl>
    implements _$$ModelNotificationPreferenceUpdateRequestImplCopyWith<$Res> {
  __$$ModelNotificationPreferenceUpdateRequestImplCopyWithImpl(
      _$ModelNotificationPreferenceUpdateRequestImpl _value,
      $Res Function(_$ModelNotificationPreferenceUpdateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelNotificationPreferenceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? id = freezed,
    Object? enabled = freezed,
  }) {
    return _then(_$ModelNotificationPreferenceUpdateRequestImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelNotificationPreferenceUpdateRequestImpl
    implements _ModelNotificationPreferenceUpdateRequest {
  _$ModelNotificationPreferenceUpdateRequestImpl(
      {this.type, this.id, this.enabled});

  factory _$ModelNotificationPreferenceUpdateRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ModelNotificationPreferenceUpdateRequestImplFromJson(json);

  @override
  final String? type;
  @override
  final int? id;
  @override
  final bool? enabled;

  @override
  String toString() {
    return 'ModelNotificationPreferenceUpdateRequest(type: $type, id: $id, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelNotificationPreferenceUpdateRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, id, enabled);

  /// Create a copy of ModelNotificationPreferenceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelNotificationPreferenceUpdateRequestImplCopyWith<
          _$ModelNotificationPreferenceUpdateRequestImpl>
      get copyWith =>
          __$$ModelNotificationPreferenceUpdateRequestImplCopyWithImpl<
              _$ModelNotificationPreferenceUpdateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelNotificationPreferenceUpdateRequestImplToJson(
      this,
    );
  }
}

abstract class _ModelNotificationPreferenceUpdateRequest
    implements ModelNotificationPreferenceUpdateRequest {
  factory _ModelNotificationPreferenceUpdateRequest(
      {final String? type,
      final int? id,
      final bool? enabled}) = _$ModelNotificationPreferenceUpdateRequestImpl;

  factory _ModelNotificationPreferenceUpdateRequest.fromJson(
          Map<String, dynamic> json) =
      _$ModelNotificationPreferenceUpdateRequestImpl.fromJson;

  @override
  String? get type;
  @override
  int? get id;
  @override
  bool? get enabled;

  /// Create a copy of ModelNotificationPreferenceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelNotificationPreferenceUpdateRequestImplCopyWith<
          _$ModelNotificationPreferenceUpdateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
