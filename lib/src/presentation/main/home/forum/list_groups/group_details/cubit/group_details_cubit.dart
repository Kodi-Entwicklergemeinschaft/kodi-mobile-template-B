// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/data/model/model_group_members.dart';
import 'package:your_app_name/src/data/model/model_group_posts.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/data/repository/forum_repository.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/utils/configs/key_helper.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart';

import '../../../../../../../utils/common.dart';
import 'group_details_state.dart';

enum RemoveUser { error, removed, onlyAdmin, onlyUser }

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  final ForumRepository repo;
  final ForumGroupModel arguments;
  late int forumId;
  int _currentOffset = 1;
  bool isPrivate = false;

  GroupDetailsCubit(this.repo, this.arguments)
      : super(const GroupDetailsStateLoading()) {
    forumId = arguments.id ?? 1;
    isPrivate = arguments.isPrivate == 1;
    onLoad();
  }

  Future<void> onLoad() async {
    final requestGroupDetailResponse = await repo.requestGroupDetails(
        arguments.id ?? 1, arguments.cityId ?? 1);
    final response = requestGroupDetailResponse!.data;
    final group = ForumGroupModel(
      id: response['id'],
      forumName: response['forumName'],
      description: formatDescription(response['description']),
      cityId: arguments.cityId,
      cityIds: arguments.cityIds,
      image: response['image'],
      isRequested: arguments.isRequested,
      isJoined: arguments.isJoined,
      isPrivate: response['isPrivate'],
      createdAt: response['createdAt'],
    );

    final userId = await UserRepository.getLoggedUserId();
    final groupMembersList = await _fetchGroupMembers(forumId, group.cityId);

    bool isAdmin = false;
    if (groupMembersList.isNotEmpty) {
      try {
        final groupMember =
        groupMembersList.firstWhere((element) => element.userId == userId);
        isAdmin = groupMember.isAdmin == 1;
      } catch (e) {
        isAdmin = false;
      }
    }

    int memberRequestCount = 0;
    if (isAdmin && group.isPrivate == 1) {
      memberRequestCount = await repo.getMemberRequestsCount(group.id ?? 1);
    }

    emit(GroupDetailsState.loaded([], group, isAdmin, userId,
        memberRequestCount: memberRequestCount));
  }

  Future<void> requestDeleteGroup(forumId, cityId) async {
    await repo.requestDeleteForum(forumId, cityId);
  }

  String formatDescription(String text) {
    RegExp expTags = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String stringWithoutTags = text.replaceAll(expTags, '');

    Map<String, String> htmlEntities = {
      "&nbsp;": " ",
      "&amp;": "&",
    };

    htmlEntities.forEach((key, value) {
      stringWithoutTags = stringWithoutTags.replaceAll(key, value);
    });

    return stringWithoutTags;
  }

  Future<RemoveUser> removeGroupMember(groupId, cityId) async {
    final groupMembersList = await _fetchGroupMembers(groupId, cityId);

    if (groupMembersList.isEmpty) {
      return RemoveUser.error;
    }

    final adminCount =
        groupMembersList
            .where((member) => member.isAdmin == 1)
            .length;

    final userId = await UserRepository.getLoggedUserId();
    final groupMemberDetail = groupMembersList
        .firstWhere((element) => element.userId == userId, orElse: () {
      throw Exception("User not in group");
    });

    final isUserAdmin = groupMemberDetail.isAdmin == 1;

    if (!isUserAdmin) {
      await repo.removeUserFromGroup(groupId, groupMemberDetail.memberId,userId);
      return RemoveUser.removed;
    } else {
      if (groupMembersList.length > 1) {
        if (adminCount > 1) {
          await repo.removeUserFromGroup(groupId, groupMemberDetail.memberId,userId);
          return RemoveUser.removed;
        } else {
          return RemoveUser.onlyAdmin;
        }
      } else {
        return RemoveUser.onlyUser;
      }
    }
  }

  Future<List<ChatMessageModel>> receivePublicMessages(int forumId,
      bool isInitialLoad) async {
    final prefs = await Preferences.openBox();
    final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    final groupMembersList = await _fetchGroupMembers(forumId, cityId);
    final userMap = {
      for (var member in groupMembersList) member.userId: member
    };

    int? lastMessageId;
    if (!isInitialLoad) {
      final currentState = state;
      if (currentState is GroupDetailsStateMessagesLoaded &&
          currentState.messages.isNotEmpty) {
        lastMessageId = currentState.messages.first.id;
      }
    }

    final response = await Api.getForumChatMessages(
      forumId: forumId,
      cityId: cityId,
      lastMessageId: isInitialLoad ? 0 : lastMessageId,
      offset: 1,
    );

    var newMessages = <ChatMessageModel>[];

    if (response.data != null) {
      newMessages = await _processMessages(response.data, forumId, userMap);

      final currentState = state;
      var updatedMessages = <ChatMessageModel>[];

      if (isInitialLoad) {
        updatedMessages = newMessages;
      } else if (currentState is GroupDetailsStateMessagesLoaded &&
          !isInitialLoad) {
        updatedMessages = List.from(newMessages)
          ..addAll(currentState.messages);
      }

      if (currentState is GroupDetailsStateLoaded) {
        emit(GroupDetailsState.messagesLoaded(
          updatedMessages,
          currentState.arguments,
          currentState.isAdmin,
          currentState.userId,
          null,
          false,
          false,
          memberRequestCount: currentState.memberRequestCount,
        ));
      } else if (currentState is GroupDetailsStateMessagesLoaded) {
        emit(currentState.copyWith(
            messages: updatedMessages, replyMessage: null));
      } else {
        emit(GroupDetailsState.messagesLoaded(
          updatedMessages,
          arguments,
          false,
          await UserRepository.getLoggedUserId(),
          null,
          false,
          false,
          memberRequestCount: 0,
        ));
      }
    }
    _currentOffset = 2;
    return newMessages;
  }

  Future<void> sendMessage(int forumId, String message,
      ChatMessageModel? replyTo, File? file) async {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final userId = await UserRepository.getLoggedUserId();
    final user = await UserRepository.loadUser();
    final tempId = 'temp_${DateTime
        .now()
        .millisecondsSinceEpoch}';

    final optimisticMessage = ChatMessageModel(
      tempId: tempId,
      message: message,
      senderId: userId,
      userId: userId,
      username: user?.username ?? 'Unknown',
      avatarUrl: user?.image ?? 'admin/ProfilePicture.png',
      createdAt: DateTime.now().toLocal().toIso8601String(),
      forumId: forumId,
      parentMessage: replyTo?.message,
      parentId: replyTo?.id,
      status: MessageStatus.sending,
      fileUrl: file?.path,
    );

    final updatedMessages = [optimisticMessage, ...currentState.messages];
    emit(currentState.copyWith(
      messages: updatedMessages,
      replyMessage: null,
    ));

    try {
      if (isPrivate) {
        await _sendPrivateMessageInBackground(
            forumId, message, replyTo, file, tempId);
      } else {
        await _sendPublicMessageInBackground(
            forumId, message, replyTo, file, tempId);
      }
    } catch (e) {
      _markMessageAsFailed(tempId, e.toString());
    }
  }

  Future<void> retryFailedMessage(String tempId) async {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final failedMessage = currentState.messages.firstWhere(
          (msg) => msg.tempId == tempId && msg.status == MessageStatus.failed,
      orElse: () => throw Exception('Message not found'),
    );

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.tempId == tempId) {
        return msg.copyWith(status: MessageStatus.sending, errorMessage: null);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));

    try {
      final messageContent = failedMessage.message ?? '';
      final file =
      failedMessage.fileUrl != null ? File(failedMessage.fileUrl!) : null;
      if (isPrivate) {
        await _sendPrivateMessageInBackground(
          forumId,
          messageContent,
          null, // TODO: Handle reply message if needed
          file,
          tempId,
        );
      } else {
        await _sendPublicMessageInBackground(
          forumId,
          messageContent,
          null, // TODO: Handle reply message if needed
          file,
          tempId,
        );
      }
    } catch (e) {
      _markMessageAsFailed(tempId, e.toString());
    }
  }

  Future<void> fetchOlderMessages(int forumId) async {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final prefs = await Preferences.openBox();
    final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    final groupMembersList = await _fetchGroupMembers(forumId, cityId);
    final userMap = {
      for (var member in groupMembersList) member.userId: member
    };

    final response = await Api.getForumChatMessages(
      forumId: forumId,
      cityId: cityId,
      lastMessageId: 0,
      offset: _currentOffset,
    );

    if (response.data != null && (response.data as List).isNotEmpty) {
      final newMessages =
      await _processMessages(response.data, forumId, userMap);
      final updatedMessages = [...currentState.messages, ...newMessages];

      emit(currentState.copyWith(
          messages: updatedMessages,
          replyMessage: null,
          isLoadingMore: false));
      _currentOffset++;
    } else {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void resetOffset() {
    _currentOffset = 1;
  }

  Future<void> fetchUserGroupKeys(int forumId,
      {List<int>? groupKeyVersions}) async {
    await repo.fetchUserGroupKeys(forumId, version: groupKeyVersions);
  }

  Future<String> groupEncrypt(String message, String groupKey) async {
    final iv = encrypt.IV.fromSecureRandom(16);
    final key = encrypt.Key(base64Decode(groupKey));
    final encrypter =
    encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(message, iv: iv);
    return "${iv.base64}:${encrypted.base64}";
  }

  void setReplyMessage(ChatMessageModel message) {
    final currentState = state;
    if (currentState is GroupDetailsStateMessagesLoaded) {
      emit(currentState.copyWith(replyMessage: message));
    }
  }

  void clearReplyMessage() {
    final currentState = state;
    if (currentState is GroupDetailsStateMessagesLoaded) {
      emit(currentState.copyWith(replyMessage: null));
    }
  }

  Future<void> onReactionSent(int messageId, int reaction) async {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final userId = await UserRepository.getLoggedUserId();
    final user = await UserRepository.loadUser();

    final messageIndex = currentState.messages.indexWhere((m) =>
    m.id == messageId);
    if (messageIndex == -1) return;

    final message = currentState.messages[messageIndex];
    final originalReactions = List<Reactions>.from(message.reactions ?? []);

    final newReaction = Reactions(
      userId: userId,
      username: user?.username ?? 'Unknown',
      reaction: reaction,
    );

    final updatedReactions = List<Reactions>.from(originalReactions)
      ..removeWhere((r) => r.userId == userId)
      ..add(newReaction);

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    final updatedMessages = List<ChatMessageModel>.from(currentState.messages)
      ..[messageIndex] = updatedMessage;

    emit(currentState.copyWith(messages: updatedMessages));

    try {
      final result = await repo.sendReaction(
          forumId: forumId, messageId: messageId, reaction: reaction);
      if (!(result?.success ?? false)) {
        final revertedMessage = message.copyWith(reactions: originalReactions);
        final revertedMessages = List<ChatMessageModel>.from(
            currentState.messages)
          ..[messageIndex] = revertedMessage;
        emit(currentState.copyWith(messages: revertedMessages));
      }
    } catch (e) {
      final revertedMessage = message.copyWith(reactions: originalReactions);
      final revertedMessages = List<ChatMessageModel>.from(
          currentState.messages)
        ..[messageIndex] = revertedMessage;
      emit(currentState.copyWith(messages: revertedMessages));
    }
  }

  Future<void> onReactionRemoved(int messageId) async {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final userId = await UserRepository.getLoggedUserId();

    final messageIndex = currentState.messages.indexWhere((m) =>
    m.id == messageId);
    if (messageIndex == -1) return;

    final message = currentState.messages[messageIndex];
    final originalReactions = List<Reactions>.from(message.reactions ?? []);

    final userReaction = originalReactions.firstWhere((r) => r.userId == userId,
        orElse: () => Reactions());

    final updatedReactions = List<Reactions>.from(originalReactions)
      ..removeWhere((r) => r.userId == userId);

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    final updatedMessages = List<ChatMessageModel>.from(currentState.messages)
      ..[messageIndex] = updatedMessage;

    emit(currentState.copyWith(messages: updatedMessages));

    try {
      final result =
      await repo.deleteReaction(messageId: messageId, forumId: forumId);
      if (!(result?.success ?? false)) {
        final revertedMessage = message.copyWith(reactions: originalReactions);
        final revertedMessages = List<ChatMessageModel>.from(
            currentState.messages)
          ..[messageIndex] = revertedMessage;
        emit(currentState.copyWith(messages: revertedMessages));
      }
    } catch (e) {
      final revertedMessage = message.copyWith(reactions: originalReactions);
      final revertedMessages = List<ChatMessageModel>.from(
          currentState.messages)
        ..[messageIndex] = revertedMessage;
      emit(currentState.copyWith(messages: revertedMessages));
    }
  }

  void addReactionLocally(decodedEvent) {
    final loadedState = state as GroupDetailsStateMessagesLoaded;
    final chatMessages = List<ChatMessageModel>.from(loadedState.messages);
    final messageIndex = chatMessages.indexWhere(
          (message) =>
      message.id == int.tryParse(decodedEvent['data']['chatId'].toString()),
    );
    if (messageIndex != -1) {
      final message = chatMessages[messageIndex];
      final reactions = List<Reactions>.from(message.reactions ?? []);

      reactions.removeWhere(
              (reaction) => reaction.userId == decodedEvent['data']['userId']);
      reactions.add(Reactions(
        reaction: decodedEvent['data']['reaction'],
        userId: decodedEvent['data']['userId'],
        username: decodedEvent['data']['username'],
      ));

      chatMessages[messageIndex] = message.copyWith(reactions: reactions);
      emit(loadedState.copyWith(messages: chatMessages));
    }
  }

  void removeReactionLocally(decodedEvent) {
    final loadedState = state as GroupDetailsStateMessagesLoaded;
    final chatMessages = List<ChatMessageModel>.from(loadedState.messages);
    final messageIndex = chatMessages.indexWhere(
          (message) =>
      message.id == int.tryParse(decodedEvent['data']['chatId'].toString()),
    );

    if (messageIndex != -1) {
      final message = chatMessages[messageIndex];
      final reactions = List<Reactions>.from(message.reactions ?? []);

      reactions.removeWhere(
              (reaction) => reaction.userId == decodedEvent['data']['userId']);
      chatMessages[messageIndex] = message.copyWith(reactions: reactions);

      emit(loadedState.copyWith(messages: chatMessages));
    }
  }

  void removeFailedMessage(String tempId) {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final updatedMessages =
    currentState.messages.where((msg) => msg.tempId != tempId).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  void clearAllFailedMessages() {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final updatedMessages = currentState.messages
        .where((msg) => msg.status != MessageStatus.failed)
        .toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  // Private Helper Methods

  Future<List<GroupMembersModel>> _fetchGroupMembers(int groupId,
      int? cityId) async {
    final response = await repo.getGroupMembers(groupId, cityId);
    if (response?.data == null) {
      return [];
    }
    return (response!.data as List).map((memberData) {
      return GroupMembersModel(
        userId: memberData['userId'],
        username: memberData['username'],
        memberId: memberData['memberId'],
        firstname: memberData['firstname'],
        lastname: memberData['lastname'],
        image: memberData['image'],
        isAdmin: memberData['isAdmin'],
        joinedAt: memberData['joinedAt'],
      );
    }).toList();
  }

  Future<List<ChatMessageModel>> _processMessages(List<dynamic> messageData,
      int forumId, Map<int?, GroupMembersModel> userMap) async {
    final processedMessages = <ChatMessageModel>[];

    for (var data in messageData) {
      final message = ChatMessageModel.fromJson(data);
      final user = userMap[message.senderId];

      String? decryptedMessage = message.message;
      String? decryptedParentMessage = message.parentMessage;

      if (isPrivate) {
        try {
          // Handle main message
          if (decryptedMessage != null && data['groupKeyVersion'] != null) {
            decryptedMessage = await _attemptDecryption(
                decryptedMessage, forumId, data['groupKeyVersion']);
          } else if (decryptedMessage != null &&
              data['groupKeyVersion'] == null) {
            decryptedMessage = null;
          }

          // Handle parent message
          if (decryptedParentMessage != null &&
              data['parentGroupKeyVersion'] != null) {
            decryptedParentMessage = await _attemptDecryption(
                decryptedParentMessage, forumId, data['parentGroupKeyVersion']);
          } else if (decryptedParentMessage != null &&
              data['parentGroupKeyVersion'] == null) {
            decryptedParentMessage = null;
          }
        } catch (e) {
          logError('Failed to decrypt message ${data['id']}', e.toString());
          decryptedMessage = null;
          decryptedParentMessage = null;
        }
      }

      if ((decryptedMessage != null && decryptedMessage.isNotEmpty) ||
          (message.fileUrl != null && message.fileUrl!.isNotEmpty)) {
        processedMessages.add(
          message.copyWith(
            username: user?.username ?? "Unknown",
            avatarUrl: user?.image ?? "admin/ProfilePicture.png",
            message: decryptedMessage,
            parentMessage: decryptedParentMessage,
          ),
        );
      }
    }
    return processedMessages;
  }

  Future<String> _attemptDecryption(String encryptedMessage, int forumId,
      int groupKeyVersion) async {
    String? groupKeyData = await KeyHelper.getForumKey(
      forumId: forumId.toString(),
      groupKeyVersion: groupKeyVersion,
    );

    if (groupKeyData == null) {
      await fetchUserGroupKeys(forumId, groupKeyVersions: [groupKeyVersion]);
      groupKeyData = await KeyHelper.getForumKey(
        forumId: forumId.toString(),
        groupKeyVersion: groupKeyVersion,
      );
    }

    if (groupKeyData != null) {
      try {
        return _decryptMessageContent(encryptedMessage, groupKeyData);
      } catch (e) {
        // Decryption failed, fallback to latest key
      }
    }

    await fetchUserGroupKeys(forumId);
    final latestGroupKeyVersion =
    await KeyHelper.getStoredForumKeyVersion(forumId.toString());
    if (latestGroupKeyVersion != null) {
      groupKeyData = await KeyHelper.getForumKey(
        forumId: forumId.toString(),
        groupKeyVersion: latestGroupKeyVersion,
      );

      if (groupKeyData != null) {
        try {
          return _decryptMessageContent(encryptedMessage, groupKeyData);
        } catch (e) {
          throw Exception('Decryption failed with latest group key');
        }
      }
    }
    throw Exception('Failed to retrieve group key');
  }

  String _decryptMessageContent(String encryptedMessage, String groupKey) {
    final decrypted = KeyHelper.decryptMessage(encryptedMessage, groupKey);
    final decryptedJson = jsonDecode(decrypted);
    return decryptedJson['message'];
  }

  Future<void> _sendPublicMessageInBackground(int forumId, String message,
      ChatMessageModel? replyTo, File? file, String tempId) async {
    try {
      final formData = FormData.fromMap({
        if (message.isNotEmpty) 'message': message,
        if (replyTo != null) 'parentId': replyTo.id.toString(),
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            contentType: Utils().getMediaType(file.path),
            filename: file.path
                .split(Platform.pathSeparator)
                .last,
          ),
      });

      final response =
      await Api.sendChatMessage(forumId: forumId, forumData: formData);

      if (response.success) {
        _replaceOptimisticMessage(
            tempId, ChatMessageModel.fromJson(response.data));
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to send public message: $e');
    }
  }

  Future<void> _sendPrivateMessageInBackground(int forumId, String message,
      ChatMessageModel? replyTo, File? file, String tempId) async {
    try {
      dynamic response;
      for (var i = 0; i < 2; i++) {
        // Max 1 retry
        final userId = await UserRepository.getLoggedUserId();
        final privateKeyPem = await KeyHelper.getPrivateKey(userId.toString());

        final messageBytes = utf8.encode(message);
        final signMessage = await RSA.signPKCS1v15(
            base64Encode(messageBytes), Hash.MD5, privateKeyPem);

        final latestGroupKey = await _getLatestGroupKey(forumId);
        if (latestGroupKey == null) {
          throw Exception('No valid group key');
        }

        final encryptedMessage = await groupEncrypt(
            jsonEncode({
              'message': message,
              'signature': signMessage,
            }),
            latestGroupKey);

        final groupKeyVersion =
        await KeyHelper.getStoredForumKeyVersion(forumId.toString());

        final formData = FormData.fromMap({
          if (message.isNotEmpty) 'message': encryptedMessage,
          'groupKeyVersion': groupKeyVersion,
          if (replyTo != null) 'parentId': replyTo.id.toString(),
          if (file != null)
            'file': await MultipartFile.fromFile(
              file.path,
              contentType: Utils().getMediaType(file.path),
              filename: file.path
                  .split(Platform.pathSeparator)
                  .last,
            ),
        });

        response =
        await Api.sendChatMessage(forumId: forumId, forumData: formData);

        if (response.success) {
          break;
        }

        if (response.message.contains("groupKeyVersion is not the latest") &&
            i == 0) {
          await fetchUserGroupKeys(forumId);
        } else {
          throw Exception(response.message);
        }
      }

      if (response.success) {
        var chatMessage = ChatMessageModel.fromJson(response.data);
        chatMessage = chatMessage.copyWith(
            message: message, parentMessage: replyTo?.message);
        _replaceOptimisticMessage(tempId, chatMessage);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to send private message: $e');
    }
  }

  void _replaceOptimisticMessage(String tempId,
      ChatMessageModel serverMessage) {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.tempId == tempId) {
        return serverMessage.copyWith(status: MessageStatus.sent);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  void _markMessageAsFailed(String tempId, String errorMessage) {
    final currentState = state;
    if (currentState is! GroupDetailsStateMessagesLoaded) return;

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.tempId == tempId) {
        return msg.copyWith(
          status: MessageStatus.failed,
          errorMessage: errorMessage,
        );
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  Future<String?> _getLatestGroupKey(int forumId) async {
    final storedForumKeyVersion =
    await KeyHelper.getStoredForumKeyVersion(forumId.toString());

    if (storedForumKeyVersion != null) {
      return await KeyHelper.getForumKey(
        forumId: forumId.toString(),
        groupKeyVersion: storedForumKeyVersion,
      );
    }
    return null;
  }

  Future<void> updateMemberRequestCount() async {
    try {
      final currentState = state;
      int memberRequestCount = 0;
        memberRequestCount = await repo.getMemberRequestsCount(forumId ?? 1);


      if (currentState is GroupDetailsStateLoaded) {
        emit(currentState.copyWith(
            memberRequestCount: memberRequestCount));
      } else if (currentState is GroupDetailsStateMessagesLoaded) {
        emit(currentState.copyWith(
            memberRequestCount: memberRequestCount));
      }
    }
    catch (e) {
      logError('Failed to update member request count', e.toString());
    }
  }

}