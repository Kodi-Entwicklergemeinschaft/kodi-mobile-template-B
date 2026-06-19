// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificaitonPreferencesModel _$NotificaitonPreferencesModelFromJson(
    Map<String, dynamic> json) {
  return _PreferenceModel.fromJson(json);
}

/// @nodoc
mixin _$NotificaitonPreferencesModel {
  bool? get enabled => throw _privateConstructorUsedError;
  List<PreferenceCategory>? get preferences =>
      throw _privateConstructorUsedError;

  /// Serializes this NotificaitonPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificaitonPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificaitonPreferencesModelCopyWith<NotificaitonPreferencesModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificaitonPreferencesModelCopyWith<$Res> {
  factory $NotificaitonPreferencesModelCopyWith(
          NotificaitonPreferencesModel value,
          $Res Function(NotificaitonPreferencesModel) then) =
      _$NotificaitonPreferencesModelCopyWithImpl<$Res,
          NotificaitonPreferencesModel>;
  @useResult
  $Res call({bool? enabled, List<PreferenceCategory>? preferences});
}

/// @nodoc
class _$NotificaitonPreferencesModelCopyWithImpl<$Res,
        $Val extends NotificaitonPreferencesModel>
    implements $NotificaitonPreferencesModelCopyWith<$Res> {
  _$NotificaitonPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificaitonPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<PreferenceCategory>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreferenceModelImplCopyWith<$Res>
    implements $NotificaitonPreferencesModelCopyWith<$Res> {
  factory _$$PreferenceModelImplCopyWith(_$PreferenceModelImpl value,
          $Res Function(_$PreferenceModelImpl) then) =
      __$$PreferenceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? enabled, List<PreferenceCategory>? preferences});
}

/// @nodoc
class __$$PreferenceModelImplCopyWithImpl<$Res>
    extends _$NotificaitonPreferencesModelCopyWithImpl<$Res,
        _$PreferenceModelImpl> implements _$$PreferenceModelImplCopyWith<$Res> {
  __$$PreferenceModelImplCopyWithImpl(
      _$PreferenceModelImpl _value, $Res Function(_$PreferenceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificaitonPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_$PreferenceModelImpl(
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferences: freezed == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<PreferenceCategory>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferenceModelImpl implements _PreferenceModel {
  _$PreferenceModelImpl(
      {this.enabled, final List<PreferenceCategory>? preferences})
      : _preferences = preferences;

  factory _$PreferenceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferenceModelImplFromJson(json);

  @override
  final bool? enabled;
  final List<PreferenceCategory>? _preferences;
  @override
  List<PreferenceCategory>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableListView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'NotificaitonPreferencesModel(enabled: $enabled, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferenceModelImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, enabled, const DeepCollectionEquality().hash(_preferences));

  /// Create a copy of NotificaitonPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferenceModelImplCopyWith<_$PreferenceModelImpl> get copyWith =>
      __$$PreferenceModelImplCopyWithImpl<_$PreferenceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferenceModelImplToJson(
      this,
    );
  }
}

abstract class _PreferenceModel implements NotificaitonPreferencesModel {
  factory _PreferenceModel(
      {final bool? enabled,
      final List<PreferenceCategory>? preferences}) = _$PreferenceModelImpl;

  factory _PreferenceModel.fromJson(Map<String, dynamic> json) =
      _$PreferenceModelImpl.fromJson;

  @override
  bool? get enabled;
  @override
  List<PreferenceCategory>? get preferences;

  /// Create a copy of NotificaitonPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferenceModelImplCopyWith<_$PreferenceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreferenceCategory _$PreferenceCategoryFromJson(Map<String, dynamic> json) {
  return _PreferenceCategory.fromJson(json);
}

/// @nodoc
mixin _$PreferenceCategory {
  String? get type => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  List<PreferenceItem>? get preferences => throw _privateConstructorUsedError;

  /// Serializes this PreferenceCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreferenceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreferenceCategoryCopyWith<PreferenceCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferenceCategoryCopyWith<$Res> {
  factory $PreferenceCategoryCopyWith(
          PreferenceCategory value, $Res Function(PreferenceCategory) then) =
      _$PreferenceCategoryCopyWithImpl<$Res, PreferenceCategory>;
  @useResult
  $Res call({String? type, String? name, List<PreferenceItem>? preferences});
}

/// @nodoc
class _$PreferenceCategoryCopyWithImpl<$Res, $Val extends PreferenceCategory>
    implements $PreferenceCategoryCopyWith<$Res> {
  _$PreferenceCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreferenceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? name = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<PreferenceItem>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreferenceCategoryImplCopyWith<$Res>
    implements $PreferenceCategoryCopyWith<$Res> {
  factory _$$PreferenceCategoryImplCopyWith(_$PreferenceCategoryImpl value,
          $Res Function(_$PreferenceCategoryImpl) then) =
      __$$PreferenceCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? type, String? name, List<PreferenceItem>? preferences});
}

/// @nodoc
class __$$PreferenceCategoryImplCopyWithImpl<$Res>
    extends _$PreferenceCategoryCopyWithImpl<$Res, _$PreferenceCategoryImpl>
    implements _$$PreferenceCategoryImplCopyWith<$Res> {
  __$$PreferenceCategoryImplCopyWithImpl(_$PreferenceCategoryImpl _value,
      $Res Function(_$PreferenceCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PreferenceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? name = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_$PreferenceCategoryImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: freezed == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<PreferenceItem>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferenceCategoryImpl implements _PreferenceCategory {
  _$PreferenceCategoryImpl(
      {this.type, this.name, final List<PreferenceItem>? preferences})
      : _preferences = preferences;

  factory _$PreferenceCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferenceCategoryImplFromJson(json);

  @override
  final String? type;
  @override
  final String? name;
  final List<PreferenceItem>? _preferences;
  @override
  List<PreferenceItem>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableListView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PreferenceCategory(type: $type, name: $name, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferenceCategoryImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, name,
      const DeepCollectionEquality().hash(_preferences));

  /// Create a copy of PreferenceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferenceCategoryImplCopyWith<_$PreferenceCategoryImpl> get copyWith =>
      __$$PreferenceCategoryImplCopyWithImpl<_$PreferenceCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferenceCategoryImplToJson(
      this,
    );
  }
}

abstract class _PreferenceCategory implements PreferenceCategory {
  factory _PreferenceCategory(
      {final String? type,
      final String? name,
      final List<PreferenceItem>? preferences}) = _$PreferenceCategoryImpl;

  factory _PreferenceCategory.fromJson(Map<String, dynamic> json) =
      _$PreferenceCategoryImpl.fromJson;

  @override
  String? get type;
  @override
  String? get name;
  @override
  List<PreferenceItem>? get preferences;

  /// Create a copy of PreferenceCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferenceCategoryImplCopyWith<_$PreferenceCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreferenceItem _$PreferenceItemFromJson(Map<String, dynamic> json) {
  return _PreferenceItem.fromJson(json);
}

/// @nodoc
mixin _$PreferenceItem {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  bool? get enabled => throw _privateConstructorUsedError;

  /// Serializes this PreferenceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreferenceItemCopyWith<PreferenceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferenceItemCopyWith<$Res> {
  factory $PreferenceItemCopyWith(
          PreferenceItem value, $Res Function(PreferenceItem) then) =
      _$PreferenceItemCopyWithImpl<$Res, PreferenceItem>;
  @useResult
  $Res call({int? id, String? name, bool? enabled});
}

/// @nodoc
class _$PreferenceItemCopyWithImpl<$Res, $Val extends PreferenceItem>
    implements $PreferenceItemCopyWith<$Res> {
  _$PreferenceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? enabled = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreferenceItemImplCopyWith<$Res>
    implements $PreferenceItemCopyWith<$Res> {
  factory _$$PreferenceItemImplCopyWith(_$PreferenceItemImpl value,
          $Res Function(_$PreferenceItemImpl) then) =
      __$$PreferenceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, bool? enabled});
}

/// @nodoc
class __$$PreferenceItemImplCopyWithImpl<$Res>
    extends _$PreferenceItemCopyWithImpl<$Res, _$PreferenceItemImpl>
    implements _$$PreferenceItemImplCopyWith<$Res> {
  __$$PreferenceItemImplCopyWithImpl(
      _$PreferenceItemImpl _value, $Res Function(_$PreferenceItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PreferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? enabled = freezed,
  }) {
    return _then(_$PreferenceItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: freezed == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferenceItemImpl implements _PreferenceItem {
  _$PreferenceItemImpl({this.id, this.name, this.enabled});

  factory _$PreferenceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferenceItemImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final bool? enabled;

  @override
  String toString() {
    return 'PreferenceItem(id: $id, name: $name, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferenceItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, enabled);

  /// Create a copy of PreferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferenceItemImplCopyWith<_$PreferenceItemImpl> get copyWith =>
      __$$PreferenceItemImplCopyWithImpl<_$PreferenceItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferenceItemImplToJson(
      this,
    );
  }
}

abstract class _PreferenceItem implements PreferenceItem {
  factory _PreferenceItem(
      {final int? id,
      final String? name,
      final bool? enabled}) = _$PreferenceItemImpl;

  factory _PreferenceItem.fromJson(Map<String, dynamic> json) =
      _$PreferenceItemImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  bool? get enabled;

  /// Create a copy of PreferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferenceItemImplCopyWith<_$PreferenceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
