import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/data/model/model_group_posts.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';

part 'group_details_state.freezed.dart';

@freezed
class GroupDetailsState with _$GroupDetailsState {
  const factory GroupDetailsState.initial() = GroupDetailsStateInitial;

  const factory GroupDetailsState.loading() = GroupDetailsStateLoading;
  const factory GroupDetailsState.loaded(
    List<GroupPostsModel> list,
    ForumGroupModel arguments,
    bool isAdmin,
    int userId, {
    int? memberRequestCount,
  }) = GroupDetailsStateLoaded;
  const factory GroupDetailsState.messagesLoaded(
    List<ChatMessageModel> messages,
    ForumGroupModel arguments,
    bool isAdmin,
    int userId,
      ChatMessageModel? replyMessage,
      bool isLoadingMore,
    bool? isSendingMessage, {
    int? memberRequestCount,
  }) = GroupDetailsStateMessagesLoaded;

  const factory GroupDetailsState.error(String error) = GroupDetailsStateError;
}
