import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = ChatStateInitial;

  const factory ChatState.loading() = ChatStateLoading;

  const factory ChatState.loaded(
    List<ChatMessageModel> chatMessages,
    ForumGroupModel forumDetails,
    bool isAdmin,
    int userId,
  ) = ChatStateLoaded;

  const factory ChatState.error(String error) = ChatStateError;
}
