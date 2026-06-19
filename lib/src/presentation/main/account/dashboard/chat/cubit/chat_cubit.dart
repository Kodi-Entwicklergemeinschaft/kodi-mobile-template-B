import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/repository/chat_repository.dart';
import 'package:your_app_name/src/presentation/main/account/dashboard/chat/cubit/chat_state.dart';

import '../../../../../../data/model/model_forum_group.dart';
import '../../../../../../utils/configs/preferences.dart';
import '../../../../../cubit/app_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repo;
  int currentPage = 1;
  int? listingId;

  ChatCubit(this.repo) : super(const ChatStateInitial());
  Future<void> onLoad(
    int listingId, {
    bool showLoading = true,
  }) async {
    this.listingId = listingId;

    if (showLoading) {
      emit(const ChatStateLoading());
    }

    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    UserModel? user = await AppBloc.userCubit.onLoadUser();

    currentPage = 1;
    final result = await repo.requestChatMessagesForPost(
      listingId: listingId,
      isReversed: true,
      pageNo: 1,
      pageSize: 15,
    );
    if (result?.success ?? false) {
      debugPrint("chat messages loaded");

      if (showLoading) {
        // For initial load, create new state
        emit(ChatStateLoaded(
          await _processMessages(result!.data),
          ForumGroupModel(
            id: 1,
            forumId: 101,
            forumName: "Feedback",
            createdAt: "2023-01-15T08:30:00Z",
            description: "A group for discussing the latest in technology.",
            image: "https://example.com/tech_group.png",
            isPrivate: 0,
            cityId: 1,
            isJoined: true,
            isRequested: false,
          ),
          true,
          userId,
          user?.username ?? "Unknown",
          false,
          null,
          false,
        ));
      } else {
        // For refresh, update existing state if it's loaded
        final currentState = state;
        if (currentState is ChatStateLoaded) {
          emit(currentState.copyWith(
            chatMessages: await _processMessages(result!.data),
          ));
        }
      }
    } else {
      if (showLoading) {
        emit(const ChatStateError("something went wrong"));
      }
    }
  }

  Future<void> loadOldMessages() async {
    final currentState = state;
    if (currentState is! ChatStateLoaded) return;
    if (currentState.isLoadingMore) return; // Check if not already loading

    emit(currentState.copyWith(isLoadingMore: true)); // Set loading flag

    final nextPage = currentPage + 1;
    final result = await repo.requestChatMessagesForPost(
      listingId: listingId!,
      isReversed: true,
      pageNo: nextPage,
    );

    if (result?.success ?? false) {
      final newMessages = await _processMessages(result!.data);

      if (newMessages.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        currentPage =
            nextPage; // Update current page only if new messages are loaded
        final updatedMessages =
            List<ChatMessageModel>.from(currentState.chatMessages)
              ..addAll(newMessages); // Add new messages to the existing list
        emit(
          currentState.copyWith(
            chatMessages: updatedMessages,
            isLoadingMore: false, // Reset loading flag
          ),
        );
      }
    } else {
      // Reset loading flag in case of error, no need to decrement page
      // as it wasn't incremented due to the check at the beginning or error.
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> onMessageSent(int listingId, String message,
      ChatMessageModel? replyTo, File? file) async {
    final loadedState = state as ChatStateLoaded;
    emit(loadedState.copyWith(isSendingMessages: true));

    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    UserModel? user = await AppBloc.userCubit.onLoadUser();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Create optimistic message
    final optimisticMessage = ChatMessageModel(
      tempId: tempId,
      message: message,
      senderId: userId,
      userId: userId,
      username: user?.username ?? 'Unknown',
      avatarUrl: user?.image ?? 'admin/ProfilePicture.png',
      createdAt: DateTime.now().toLocal().toIso8601String(),
      parentMessage: replyTo?.message,
      parentId: replyTo?.id,
      parentUsername: replyTo?.username,
      status: MessageStatus.sending,
      fileUrl: file?.path,
    );

    // Add message locally first (optimistic UI)
    final updatedMessages = [optimisticMessage, ...loadedState.chatMessages];
    emit(loadedState.copyWith(
      chatMessages: updatedMessages,
      replyMessage: null,
    ));
    final result =
        await repo.sendChatMessageForPost(listingId, message, replyTo, file);
    if (result?.success ?? false) {
      debugPrint("message sent");
      _replaceOptimisticMessage(
          tempId, ChatMessageModel.fromJson(result?.data));
    } else {
      // Mark message as failed
      _markMessageAsFailed(tempId, result?.message ?? 'Failed to send message');
      emit(loadedState.copyWith(isSendingMessages: false));
    }
  }

  void _replaceOptimisticMessage(
      String tempId, ChatMessageModel serverMessage) {
    final currentState = state;
    if (currentState is! ChatStateLoaded) return;

    final updatedMessages = currentState.chatMessages.map((msg) {
      if (msg.tempId == tempId) {
        return serverMessage.copyWith(status: MessageStatus.sent);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(chatMessages: updatedMessages));
  }

  Future<void> onReactionSent(int messageId, int reaction) async {
    final result = await repo.sendReactionForMessage(
        listingId: listingId!, messageId: messageId, reaction: reaction);
    if (result?.success ?? false) {
      debugPrint("reaction added");
    } else {
      debugPrint("error while reaction add");
    }
  }

  Future<void> onReactionRemoved(int messageId) async {
    final result =
        await repo.deleteReaction(messageId: messageId, listingId: listingId!);
    if (result?.success ?? false) {
      debugPrint("reaction removed");
    } else {
      debugPrint("error while reaction removed");
    }
  }

  Future<List<ChatMessageModel>> _processMessages(
      List<dynamic> messageData) async {
    List<ChatMessageModel> processedMessages = [];

    for (var data in messageData) {
      final message = ChatMessageModel.fromJson(data);

      String decryptedMessage = data['message'] ?? "";

      // try {
      //   if (isPrivate) {
      //     decryptedMessage = await _attemptDecryption(
      //         data['message'], forumId, data['groupKeyVersion']);
      //   }
      // } catch (e) {
      //   // decryptedMessage = "Decryption failed";
      //   logError('Failed to decrypt message ${data['id']}', e.toString());
      //   continue;
      // }

      processedMessages.add(
        message.copyWith(
          // username: user?.username ?? "Unknown",
          // avatarUrl: user?.image ?? "admin/ProfilePicture.png",
          message: decryptedMessage.isNotEmpty ? decryptedMessage : "",
        ),
      );
    }

    return processedMessages;
  }

  void setReplyMessage(ChatMessageModel message) {
    final loadedState = state as ChatStateLoaded;
    emit(loadedState.copyWith(replyMessage: message));
  }

  void clearReplyMessage() {
    final loadedState = state as ChatStateLoaded;
    emit(loadedState.copyWith(
        replyMessage: null)); // This correctly sets replyMessage to null.
  }

  void addReactionLocally(decodedEvent) {
    final loadedState = state as ChatStateLoaded;
    final chatMessages = List<ChatMessageModel>.from(loadedState.chatMessages);
    final messageIndex = chatMessages.indexWhere(
      (message) =>
          message.id == int.tryParse(decodedEvent['data']['chatId'].toString()),
    );
    if (messageIndex != -1) {
      final message = chatMessages[messageIndex];
      final reactions = List<Reactions>.from(message.reactions ?? []);

      // Remove existing reaction from the user if any
      reactions.removeWhere(
          (reaction) => reaction.userId == decodedEvent['data']['userId']);

      // Add the new reaction
      reactions.add(Reactions(
        reaction: decodedEvent['data']['reaction'],
        userId: decodedEvent['data']['userId'],
        username: decodedEvent['data']['username'],
      ));

      // Update the message with new reactions
      chatMessages[messageIndex] = message.copyWith(reactions: reactions);

      emit(loadedState.copyWith(chatMessages: chatMessages));
    }
  }

  void removeReactionLocally(decodedEvent) {
    final loadedState = state as ChatStateLoaded;
    final chatMessages = List<ChatMessageModel>.from(loadedState.chatMessages);
    final messageIndex = chatMessages.indexWhere(
      (message) =>
          message.id == int.tryParse(decodedEvent['data']['chatId'].toString()),
    );

    if (messageIndex != -1) {
      final message = chatMessages[messageIndex];
      final reactions = List<Reactions>.from(message.reactions ?? []);

      // Remove existing reaction from the user if any
      reactions.removeWhere(
          (reaction) => reaction.userId == decodedEvent['data']['userId']);
      chatMessages[messageIndex] = message.copyWith(reactions: reactions);
      emit(loadedState.copyWith(chatMessages: chatMessages));
    }
  }

  /// Marks a message as failed with an error message
  void _markMessageAsFailed(String tempId, String errorMessage) {
    final currentState = state;
    if (currentState is! ChatStateLoaded) return;

    final updatedMessages = currentState.chatMessages.map((msg) {
      if (msg.tempId == tempId) {
        return msg.copyWith(
          status: MessageStatus.failed,
          errorMessage: errorMessage,
        );
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(chatMessages: updatedMessages));
  }

  /// Retries sending a failed message
  Future<void> retryFailedMessage(ChatMessageModel failedMessage) async {
    if (failedMessage.status != MessageStatus.failed ||
        failedMessage.tempId == null) {
      return;
    }

    final currentState = state;
    if (currentState is! ChatStateLoaded) return;

    // Mark message as sending again
    final updatedMessages = currentState.chatMessages.map((msg) {
      if (msg.tempId == failedMessage.tempId) {
        return msg.copyWith(
          status: MessageStatus.sending,
          errorMessage: null,
        );
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(chatMessages: updatedMessages));

    // Retry sending the message
    final result = await repo.sendChatMessageForPost(
      listingId!,
      failedMessage.message!,
      failedMessage.parentId != null
          ? ChatMessageModel(
              id: failedMessage.parentId,
              message: failedMessage.parentMessage,
              username: failedMessage.parentUsername,
            )
          : null,
      failedMessage.fileUrl != null ? File(failedMessage.fileUrl!) : null,
    );

    if (result?.success ?? false) {
      debugPrint("message retry successful");
      _replaceOptimisticMessage(
          failedMessage.tempId!, ChatMessageModel.fromJson(result?.data));
    } else {
      // Mark as failed again
      _markMessageAsFailed(
          failedMessage.tempId!, result?.message ?? 'Failed to send message');
    }
  }

  /// Removes failed messages that couldn't be sent
  void removeFailedMessage(String tempId) {
    final currentState = state;
    if (currentState is! ChatStateLoaded) return;

    final updatedMessages =
        currentState.chatMessages.where((msg) => msg.tempId != tempId).toList();

    emit(currentState.copyWith(chatMessages: updatedMessages));
  }
}
