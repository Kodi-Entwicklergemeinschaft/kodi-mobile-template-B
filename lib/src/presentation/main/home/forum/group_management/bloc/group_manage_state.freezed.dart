// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_manage_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GroupManageState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ForumGroupModel> list) loaded,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ForumGroupModel> list)? loaded,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ForumGroupModel> list)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupManageLoading value) loading,
    required TResult Function(GroupManageLoaded value) loaded,
    required TResult Function(GroupManageError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupManageLoading value)? loading,
    TResult? Function(GroupManageLoaded value)? loaded,
    TResult? Function(GroupManageError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupManageLoading value)? loading,
    TResult Function(GroupManageLoaded value)? loaded,
    TResult Function(GroupManageError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupManageStateCopyWith<$Res> {
  factory $GroupManageStateCopyWith(
          GroupManageState value, $Res Function(GroupManageState) then) =
      _$GroupManageStateCopyWithImpl<$Res, GroupManageState>;
}

/// @nodoc
class _$GroupManageStateCopyWithImpl<$Res, $Val extends GroupManageState>
    implements $GroupManageStateCopyWith<$Res> {
  _$GroupManageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GroupManageLoadingImplCopyWith<$Res> {
  factory _$$GroupManageLoadingImplCopyWith(_$GroupManageLoadingImpl value,
          $Res Function(_$GroupManageLoadingImpl) then) =
      __$$GroupManageLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupManageLoadingImplCopyWithImpl<$Res>
    extends _$GroupManageStateCopyWithImpl<$Res, _$GroupManageLoadingImpl>
    implements _$$GroupManageLoadingImplCopyWith<$Res> {
  __$$GroupManageLoadingImplCopyWithImpl(_$GroupManageLoadingImpl _value,
      $Res Function(_$GroupManageLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GroupManageLoadingImpl implements GroupManageLoading {
  const _$GroupManageLoadingImpl();

  @override
  String toString() {
    return 'GroupManageState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupManageLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ForumGroupModel> list) loaded,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ForumGroupModel> list)? loaded,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ForumGroupModel> list)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupManageLoading value) loading,
    required TResult Function(GroupManageLoaded value) loaded,
    required TResult Function(GroupManageError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupManageLoading value)? loading,
    TResult? Function(GroupManageLoaded value)? loaded,
    TResult? Function(GroupManageError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupManageLoading value)? loading,
    TResult Function(GroupManageLoaded value)? loaded,
    TResult Function(GroupManageError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GroupManageLoading implements GroupManageState {
  const factory GroupManageLoading() = _$GroupManageLoadingImpl;
}

/// @nodoc
abstract class _$$GroupManageLoadedImplCopyWith<$Res> {
  factory _$$GroupManageLoadedImplCopyWith(_$GroupManageLoadedImpl value,
          $Res Function(_$GroupManageLoadedImpl) then) =
      __$$GroupManageLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ForumGroupModel> list});
}

/// @nodoc
class __$$GroupManageLoadedImplCopyWithImpl<$Res>
    extends _$GroupManageStateCopyWithImpl<$Res, _$GroupManageLoadedImpl>
    implements _$$GroupManageLoadedImplCopyWith<$Res> {
  __$$GroupManageLoadedImplCopyWithImpl(_$GroupManageLoadedImpl _value,
      $Res Function(_$GroupManageLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? list = null,
  }) {
    return _then(_$GroupManageLoadedImpl(
      null == list
          ? _value._list
          : list // ignore: cast_nullable_to_non_nullable
              as List<ForumGroupModel>,
    ));
  }
}

/// @nodoc

class _$GroupManageLoadedImpl implements GroupManageLoaded {
  const _$GroupManageLoadedImpl(final List<ForumGroupModel> list)
      : _list = list;

  final List<ForumGroupModel> _list;
  @override
  List<ForumGroupModel> get list {
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_list);
  }

  @override
  String toString() {
    return 'GroupManageState.loaded(list: $list)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupManageLoadedImpl &&
            const DeepCollectionEquality().equals(other._list, _list));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_list));

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupManageLoadedImplCopyWith<_$GroupManageLoadedImpl> get copyWith =>
      __$$GroupManageLoadedImplCopyWithImpl<_$GroupManageLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ForumGroupModel> list) loaded,
    required TResult Function(String error) error,
  }) {
    return loaded(list);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ForumGroupModel> list)? loaded,
    TResult? Function(String error)? error,
  }) {
    return loaded?.call(list);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ForumGroupModel> list)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(list);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupManageLoading value) loading,
    required TResult Function(GroupManageLoaded value) loaded,
    required TResult Function(GroupManageError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupManageLoading value)? loading,
    TResult? Function(GroupManageLoaded value)? loaded,
    TResult? Function(GroupManageError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupManageLoading value)? loading,
    TResult Function(GroupManageLoaded value)? loaded,
    TResult Function(GroupManageError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class GroupManageLoaded implements GroupManageState {
  const factory GroupManageLoaded(final List<ForumGroupModel> list) =
      _$GroupManageLoadedImpl;

  List<ForumGroupModel> get list;

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupManageLoadedImplCopyWith<_$GroupManageLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GroupManageErrorImplCopyWith<$Res> {
  factory _$$GroupManageErrorImplCopyWith(_$GroupManageErrorImpl value,
          $Res Function(_$GroupManageErrorImpl) then) =
      __$$GroupManageErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$GroupManageErrorImplCopyWithImpl<$Res>
    extends _$GroupManageStateCopyWithImpl<$Res, _$GroupManageErrorImpl>
    implements _$$GroupManageErrorImplCopyWith<$Res> {
  __$$GroupManageErrorImplCopyWithImpl(_$GroupManageErrorImpl _value,
      $Res Function(_$GroupManageErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$GroupManageErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GroupManageErrorImpl implements GroupManageError {
  const _$GroupManageErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'GroupManageState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupManageErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupManageErrorImplCopyWith<_$GroupManageErrorImpl> get copyWith =>
      __$$GroupManageErrorImplCopyWithImpl<_$GroupManageErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ForumGroupModel> list) loaded,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ForumGroupModel> list)? loaded,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ForumGroupModel> list)? loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupManageLoading value) loading,
    required TResult Function(GroupManageLoaded value) loaded,
    required TResult Function(GroupManageError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupManageLoading value)? loading,
    TResult? Function(GroupManageLoaded value)? loaded,
    TResult? Function(GroupManageError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupManageLoading value)? loading,
    TResult Function(GroupManageLoaded value)? loaded,
    TResult Function(GroupManageError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GroupManageError implements GroupManageState {
  const factory GroupManageError(final String error) = _$GroupManageErrorImpl;

  String get error;

  /// Create a copy of GroupManageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupManageErrorImplCopyWith<_$GroupManageErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
