import 'dart:io';

import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:loggy/loggy.dart';

import '../model/model_result_api.dart';
import '../remote/api/api.dart';

class ChatRepository {

  Future<ResultApiModel?> sendChatMessageForPost(listingId, message,ChatMessageModel? replyTo,File? file) async {
    // Fetch chat messages
    final response =
    await Api.sendChatMessagesForPost(listingId: listingId,message: message,parentMessageId: replyTo?.id,file: file);

    if (response.success) {
      return response;
    } else {
      logError('send Chat Messages Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> requestChatMessagesForPost({required int listingId,
    int? pageNo,
    int? pageSize,
    bool isReversed=true,
  }) async {
    // Fetch chat messages
    final response =
        await Api.getChatMessagesForPost(listingId: listingId,pageSize: pageSize,isReversed: isReversed,pageNo: pageNo);

    if (response.success) {
      return response;
    } else {
      logError('Request Chat Messages Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> sendReactionForMessage(
      {required int listingId,required int messageId, required int reaction}) async {
    // Send reaction for a message
    final response = await Api.sendReactionForMessage(
      listingId:listingId,
        messageId: messageId, reaction: reaction);

    if (response.success) {
      return response;
    } else {
      logError('Send Reaction Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> deleteReaction(
      {required int listingId,required int messageId}) async {
    // Delete reaction for a message
    final response = await Api.deleteReaction(
        listingId:listingId,
        messageId: messageId);

    if (response.success) {
      return response;
    } else {
      logError('Delete Reaction Failed', response.message);
      return null;
    }
  }

}
