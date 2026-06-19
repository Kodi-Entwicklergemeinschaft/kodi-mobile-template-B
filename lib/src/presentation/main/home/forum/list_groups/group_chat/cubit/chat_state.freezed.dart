// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)
        loaded,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStateInitial value) initial,
    required TResult Function(ChatStateLoading value) loading,
    required TResult Function(ChatStateLoaded value) loaded,
    required TResult Function(ChatStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStateInitial value)? initial,
    TResult? Function(ChatStateLoading value)? loading,
    TResult? Function(ChatStateLoaded value)? loaded,
    TResult? Function(ChatStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStateInitial value)? initial,
    TResult Function(ChatStateLoading value)? loading,
    TResult Function(ChatStateLoaded value)? loaded,
    TResult Function(ChatStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChatStateInitialImplCopyWith<$Res> {
  factory _$$ChatStateInitialImplCopyWith(_$ChatStateInitialImpl value,
          $Res Function(_$ChatStateInitialImpl) then) =
      __$$ChatStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatStateInitialImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateInitialImpl>
    implements _$$ChatStateInitialImplCopyWith<$Res> {
  __$$ChatStateInitialImplCopyWithImpl(_$ChatStateInitialImpl _value,
      $Res Function(_$ChatStateInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ChatStateInitialImpl implements ChatStateInitial {
  const _$ChatStateInitialImpl();

  @override
  String toString() {
    return 'ChatState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ChatStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)
        loaded,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStateInitial value) initial,
    required TResult Function(ChatStateLoading value) loading,
    required TResult Function(ChatStateLoaded value) loaded,
    required TResult Function(ChatStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStateInitial value)? initial,
    TResult? Function(ChatStateLoading value)? loading,
    TResult? Function(ChatStateLoaded value)? loaded,
    TResult? Function(ChatStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStateInitial value)? initial,
    TResult Function(ChatStateLoading value)? loading,
    TResult Function(ChatStateLoaded value)? loaded,
    TResult Function(ChatStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ChatStateInitial implements ChatState {
  const factory ChatStateInitial() = _$ChatStateInitialImpl;
}

/// @nodoc
abstract class _$$ChatStateLoadingImplCopyWith<$Res> {
  factory _$$ChatStateLoadingImplCopyWith(_$ChatStateLoadingImpl value,
          $Res Function(_$ChatStateLoadingImpl) then) =
      __$$ChatStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatStateLoadingImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateLoadingImpl>
    implements _$$ChatStateLoadingImplCopyWith<$Res> {
  __$$ChatStateLoadingImplCopyWithImpl(_$ChatStateLoadingImpl _value,
      $Res Function(_$ChatStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ChatStateLoadingImpl implements ChatStateLoading {
  const _$ChatStateLoadingImpl();

  @override
  String toString() {
    return 'ChatState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ChatStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)
        loaded,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
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
    required TResult Function(ChatStateInitial value) initial,
    required TResult Function(ChatStateLoading value) loading,
    required TResult Function(ChatStateLoaded value) loaded,
    required TResult Function(ChatStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStateInitial value)? initial,
    TResult? Function(ChatStateLoading value)? loading,
    TResult? Function(ChatStateLoaded value)? loaded,
    TResult? Function(ChatStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStateInitial value)? initial,
    TResult Function(ChatStateLoading value)? loading,
    TResult Function(ChatStateLoaded value)? loaded,
    TResult Function(ChatStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ChatStateLoading implements ChatState {
  const factory ChatStateLoading() = _$ChatStateLoadingImpl;
}

/// @nodoc
abstract class _$$ChatStateLoadedImplCopyWith<$Res> {
  factory _$$ChatStateLoadedImplCopyWith(_$ChatStateLoadedImpl value,
          $Res Function(_$ChatStateLoadedImpl) then) =
      __$$ChatStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ChatMessageModel> chatMessages,
      ForumGroupModel forumDetails,
      bool isAdmin,
      int userId});
}

/// @nodoc
class __$$ChatStateLoadedImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateLoadedImpl>
    implements _$$ChatStateLoadedImplCopyWith<$Res> {
  __$$ChatStateLoadedImplCopyWithImpl(
      _$ChatStateLoadedImpl _value, $Res Function(_$ChatStateLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatMessages = null,
    Object? forumDetails = null,
    Object? isAdmin = null,
    Object? userId = null,
  }) {
    return _then(_$ChatStateLoadedImpl(
      null == chatMessages
          ? _value._chatMessages
          : chatMessages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessageModel>,
      null == forumDetails
          ? _value.forumDetails
          : forumDetails // ignore: cast_nullable_to_non_nullable
              as ForumGroupModel,
      null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ChatStateLoadedImpl implements ChatStateLoaded {
  const _$ChatStateLoadedImpl(final List<ChatMessageModel> chatMessages,
      this.forumDetails, this.isAdmin, this.userId)
      : _chatMessages = chatMessages;

  final List<ChatMessageModel> _chatMessages;
  @override
  List<ChatMessageModel> get chatMessages {
    if (_chatMessages is EqualUnmodifiableListView) return _chatMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chatMessages);
  }

  @override
  final ForumGroupModel forumDetails;
  @override
  final bool isAdmin;
  @override
  final int userId;

  @override
  String toString() {
    return 'ChatState.loaded(chatMessages: $chatMessages, forumDetails: $forumDetails, isAdmin: $isAdmin, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._chatMessages, _chatMessages) &&
            (identical(other.forumDetails, forumDetails) ||
                other.forumDetails == forumDetails) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_chatMessages),
      forumDetails,
      isAdmin,
      userId);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateLoadedImplCopyWith<_$ChatStateLoadedImpl> get copyWith =>
      __$$ChatStateLoadedImplCopyWithImpl<_$ChatStateLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)
        loaded,
    required TResult Function(String error) error,
  }) {
    return loaded(chatMessages, forumDetails, isAdmin, userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult? Function(String error)? error,
  }) {
    return loaded?.call(chatMessages, forumDetails, isAdmin, userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(chatMessages, forumDetails, isAdmin, userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStateInitial value) initial,
    required TResult Function(ChatStateLoading value) loading,
    required TResult Function(ChatStateLoaded value) loaded,
    required TResult Function(ChatStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStateInitial value)? initial,
    TResult? Function(ChatStateLoading value)? loading,
    TResult? Function(ChatStateLoaded value)? loaded,
    TResult? Function(ChatStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStateInitial value)? initial,
    TResult Function(ChatStateLoading value)? loading,
    TResult Function(ChatStateLoaded value)? loaded,
    TResult Function(ChatStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class ChatStateLoaded implements ChatState {
  const factory ChatStateLoaded(
      final List<ChatMessageModel> chatMessages,
      final ForumGroupModel forumDetails,
      final bool isAdmin,
      final int userId) = _$ChatStateLoadedImpl;

  List<ChatMessageModel> get chatMessages;
  ForumGroupModel get forumDetails;
  bool get isAdmin;
  int get userId;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateLoadedImplCopyWith<_$ChatStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStateErrorImplCopyWith<$Res> {
  factory _$$ChatStateErrorImplCopyWith(_$ChatStateErrorImpl value,
          $Res Function(_$ChatStateErrorImpl) then) =
      __$$ChatStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$ChatStateErrorImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateErrorImpl>
    implements _$$ChatStateErrorImplCopyWith<$Res> {
  __$$ChatStateErrorImplCopyWithImpl(
      _$ChatStateErrorImpl _value, $Res Function(_$ChatStateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$ChatStateErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChatStateErrorImpl implements ChatStateError {
  const _$ChatStateErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'ChatState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateErrorImplCopyWith<_$ChatStateErrorImpl> get copyWith =>
      __$$ChatStateErrorImplCopyWithImpl<_$ChatStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)
        loaded,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChatMessageModel> chatMessages,
            ForumGroupModel forumDetails, bool isAdmin, int userId)?
        loaded,
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
    required TResult Function(ChatStateInitial value) initial,
    required TResult Function(ChatStateLoading value) loading,
    required TResult Function(ChatStateLoaded value) loaded,
    required TResult Function(ChatStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStateInitial value)? initial,
    TResult? Function(ChatStateLoading value)? loading,
    TResult? Function(ChatStateLoaded value)? loaded,
    TResult? Function(ChatStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStateInitial value)? initial,
    TResult Function(ChatStateLoading value)? loading,
    TResult Function(ChatStateLoaded value)? loaded,
    TResult Function(ChatStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ChatStateError implements ChatState {
  const factory ChatStateError(final String error) = _$ChatStateErrorImpl;

  String get error;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateErrorImplCopyWith<_$ChatStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
