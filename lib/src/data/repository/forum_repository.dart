// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/model/model_comment.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/data/model/model_forum_status.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/model/model_request_member.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/services/firebase_messaging_service.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/key_helper.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/logger.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pointycastle/pointycastle.dart';

class ForumRepository {
  final Preferences prefs;
  ForumRepository(this.prefs);

  Future<List?> loadForumsList({required pageNo}) async {
    final hasForum = await Api.requestHasForum();

    int cityId = prefs.getKeyValue(Preferences.cityId, 0);
    if (cityId == 0) {
      cityId = 1;
    }
    int userId = prefs.getKeyValue(Preferences.userId, 0);

    bool hasForumFlag = false;

    if (hasForum.success) {
      for (var forumData in hasForum.data) {
        if (forumData['hasForum'] == 1) {
          hasForumFlag = true;
          break;
        }
      }
    }

    if (hasForumFlag) {
      final requestForumResponse = await Api.requestForum(cityId, pageNo);
      if (requestForumResponse.success) {
        final groupList =
            List.from(requestForumResponse.data ?? []).map((item) {
          return ForumGroupModel.fromJson(
            item,
          );
        }).toList();
        if (userId != 0) {
          String forumIds =
              groupList.map((item) => item.id.toString()).join(', ');
          final forumWithStatusResponse =
              await Api.requestForumStatus(userId, cityId, forumIds);

          final forumStatusList =
              List.from(forumWithStatusResponse.data ?? []).map((item) {
            return ForumStatusModel.fromJson(
              item,
            );
          }).toList();

          return [
            userId,
            groupList,
            requestForumResponse.pagination,
            forumStatusList,
          ];
        } else {
          return [
            userId,
            groupList,
          ];
        }
      }
    } else {
      logError('Forum Group List Error');
    }
    return null;
  }

  Future<List?> loadMyForumsList({required pageNo}) async {
    int userId = prefs.getKeyValue(Preferences.userId, 0);
    final usersJoinedForumResponse = await Api.requestUsersForum(userId);

    if (usersJoinedForumResponse.success) {
      final groupList =
          List.from(usersJoinedForumResponse.data ?? []).map((item) {
        return ForumGroupModel.fromJson(
          item,
        );
      }).toList();

      return [
        userId,
        groupList,
      ];
    }

    return null;
  }

  Future<List<ForumGroupModel>?> loadAllForumsListForAdmin() async {
    final result = await Api.getAllGroups();

    if (result.success) {
      final groupList = List.from(result.data ?? []).map((item) {
        return ForumGroupModel.fromJson(
          item,
        );
      }).toList();
      return groupList;
    }
    return null;
  }

  Future<ResultApiModel?> changeGroupStatus(forumId, status) async {
    try {
      final result =
          await Api.changeStatusOfForum(forumId: forumId, status: status);
      if (result.success) {
        return result;
      }
    } catch (e) {
      logError('Failed to change status of group', e.toString());
    }
    return null;
  }

  Future<int> getLoggedInUserId() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    return userId;
  }

  Future<ResultApiModel?> requestToJoinGroup(forumId) async {
    final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    String? publicKey = await _ensureUserPublicKey();

    if(publicKey!=null) {
      final response =
      await Api.requestToJoinGroup(forumId, cityId, {'publicKey': publicKey});
      // final response = await Api.requestToJoinGroup(forumId, cityId);

      if (response.success) {
        return response;
      } else {
        logError('Request To Join Group Response Failed', response.message);
        return null;
      }
    }
    else{
      logError('Request To Join Group Response Failed', "Public key is null");
      return null;
    }
  }

  bool isPrivate = false;

  Future<ResultApiModel?> requestGroupDetails(int forumId, int cityId) async {
    int prefCityId = prefs.getKeyValue(Preferences.cityId, 0);

    await _ensureUserPublicKey();

    // Fetch group details
    final response = await Api.requestGroupDetails(
      forumId,
      cityId != 0 ? cityId : prefCityId,
    );

    if (response.success) {
      handleGroupChatSubscription(forumId, true);
      isPrivate = false;

      isPrivate = response.data['isPrivate'] == 1;

      if (isPrivate) {
        try {
          await fetchUserGroupKeys(forumId);
        } catch (e) {
          logError('Failed to fetch and save forum keys', e.toString());
        }
      }

      // Fetch initial chat messages
      try {
        final chatMessagesResponse = await requestChatMessages(forumId, 0, 1);
        if (chatMessagesResponse != null && chatMessagesResponse.success) {
          response.data['chatMessages'] = chatMessagesResponse.data;
        } else {
          logError('Failed to fetch chat messages',
              chatMessagesResponse?.message ?? 'Unknown error');
        }
      } catch (e) {
        logError('Exception while fetching chat messages', e.toString());
      }

      return response;
    } else {
      logError('Request Group Detail Response Failed', response.message);
      return null;
    }
  }

  Future<String?> _ensureUserPublicKey({bool isNewGroup = false}) async {
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    // Check if public key exists for the user
    bool keyExists = await KeyHelper.checkIfKeyExists(userId.toString());
    if (!keyExists) {
      try {
        await KeyHelper.generateAndStoreRSAKeyPair(userId.toString());
      } catch (e) {
        logError('Failed to generate RSA key pair', e.toString());
      }
    }
    String? publicKey;
    publicKey = await KeyHelper.getPublicKey(userId.toString());

    if(isNewGroup || !keyExists) {
      try {
        Map<String, String> params = {'publicKey': publicKey};
        ResultApiModel keyUpdateResponse =
        await Api.updateForumKeys(params: params);
        if (!keyUpdateResponse.success) {
          logError('Failed to update forum keys', keyUpdateResponse.message);
        }
        return publicKey;
      } catch (e) {
        logError('Failed to retrieve public key', e.toString());
      }
    }
    return publicKey;
  }

  Future<ResultApiModel?> requestChatMessages(
      forumId, lastMessageId, offset) async {
    int prefCityId = prefs.getKeyValue(Preferences.cityId, 0);
    final userId = prefs.getKeyValue(Preferences.userId, 0);

    // Fetch chat messages
    final response = await Api.getForumChatMessages(
        forumId: forumId,
        cityId: prefCityId,
        lastMessageId: lastMessageId,
        offset: offset);

    if (response.success) {
      if (isPrivate) {
        return await decryptPrivateMessages(response, forumId, userId);
      } else {
        return response;
      }
    } else {
      logError('Request Chat Messages Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> decryptPrivateMessages(
      ResultApiModel response, int forumId, int userId) async {
    final List<ChatMessageModel> messages = [];
    final storedForumKeyVersion =
        await KeyHelper.getStoredForumKeyVersion(forumId.toString());

    if (storedForumKeyVersion == null) {
      await fetchUserGroupKeys(forumId);
    }

    for (var messageData in response.data) {
      final encryptedMessage = messageData['message'];
      final groupKeyVersion = messageData['groupKeyVersion'];
      String? groupKeyData = await KeyHelper.getForumKey(
        forumId: forumId.toString(),
        groupKeyVersion: groupKeyVersion,
      );

      if (groupKeyData == null) {
        await fetchUserGroupKeys(forumId, version: [groupKeyVersion]);
        groupKeyData = await KeyHelper.getForumKey(
          forumId: forumId.toString(),
          groupKeyVersion: groupKeyVersion,
        );
        if (groupKeyData == null) continue;
      }

      final decrypted = await decryptData(encryptedMessage, groupKeyData);
      final actualMessageJson = jsonDecode(decrypted);
      final actualMessage = actualMessageJson['message'];

      messages.add(ChatMessageModel(
        id: messageData['id'],
        forumId: messageData['forumId'],
        userId: messageData['userId'],
        decryptedMessage: actualMessage,
        createdAt: messageData['createdAt'],
      ));
    }

    return ResultApiModel(
        successValue: true,
        data: messages,
        pagination: response.pagination,
        messageValue: response.message);
  }

  Future<void> fetchUserGroupKeys(int forumId, {List<int>? version}) async {
    final int userId = prefs.getKeyValue(Preferences.userId, 0);
    final int cityId = prefs.getKeyValue(Preferences.cityId, 0);

    try {
      final ResultApiModel response = await Api.getForumKeys(
        forumId: forumId,
        userId: userId,
        cityId: cityId,
        params: {'groupKeyVersions': version},
      );

      if (response.success) {
        List<dynamic> groupKeyData = response.data;
        for (var element in groupKeyData) {
          String decryptedGroupKeyData = await decryptGroupKey(
            userId,
            element["encryptedForumAesKey"],
          );
          int groupKeyVersion = element['groupKeyVersion'] as int;

          await KeyHelper.storeForumKey(
            forumId: forumId.toString(),
            groupKeyVersion: groupKeyVersion.toString(),
            encryptedForumAesKey: decryptedGroupKeyData,
          );
        }
      } else {
        throw Exception('Failed to fetch group keys: ${response.message}');
      }
    } catch (e) {
      logError('Error fetching group keys', e.toString());
      throw Exception('Failed to fetch group keys');
    }
  }

  Future<String> decryptGroupKey(int userId, String encryptedValue) async {
    final privateKeyPem = await KeyHelper.getPrivateKey(userId.toString());
    final parser = encrypt.RSAKeyParser();
    final privateKey = parser.parse(privateKeyPem) as RSAPrivateKey;

    final encrypter = encrypt.Encrypter(encrypt.RSA(
        privateKey: privateKey, encoding: encrypt.RSAEncoding.OAEP));

    final encrypted = encrypt.Encrypted(base64Decode(encryptedValue));
    final decrypted = encrypter.decrypt(encrypted);
    return decrypted;
  }

  Future<String> decryptData(String encryptedData, String keyString) async {
    final parts = encryptedData.split(':');
    final ivBytes = base64Decode(parts[0]);
    final data = base64Decode(parts[1]);
    final iv = encrypt.IV(ivBytes);
    final key = base64Decode(keyString);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(data),
      iv: iv,
    );

    return decrypted;
  }

  Future<bool> removeUserFromGroup(forumId, memberId,userId) async {
    final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.removeUserFromGroup(forumId, cityId, memberId);
    if (response.success) {
      final myUserId = prefs.getKeyValue(Preferences.userId, 0);
      if(myUserId==userId) {
        handleGroupChatSubscription(forumId, false);
      }
      return true;
    } else {
      logError('Request To Remove User From Group Response Failed',
          response.message);
      return false;
    }
  }

  Future<ResultApiModel?> requestGroupPosts(forumId, cityId) async {
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response =
        await Api.requestGroupPosts(forumId, cityId == 0 ? cityIdPref : cityId);
    if (response.success) {
      return response;
    } else {
      logError('Request Group Detail Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> deleteGroupPost(forumId, cityId, postId) async {
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.deleteGroupPost(
        forumId, cityId == 0 ? cityIdPref : cityId, postId);
    if (response.success) {
      return response;
    } else {
      logError('Request Group Detail Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> reportGroupPosts(
      forumId, postId, reason, cityId) async {
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final Map<String, dynamic> params = {"Reason": reason};
    final response = await Api.reportGroupPosts(
        forumId, cityId == 0 ? cityIdPref : cityId, postId, params);
    if (response.success) {
      return response;
    } else {
      logError('Report Group Post Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> getGroupMembers(forumId, cityId) async {
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response =
        await Api.getGroupMembers(forumId, cityId == 0 ? cityIdPref : cityId);
    if (response.success) {
      return response;
    } else {
      logError('Request Group Members Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> getMemberRequests(forumId, cityId) async {
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.getMemberRequests(
      forumId,
      cityId == 0 ? cityIdPref : cityId,
    );
    if (response.success) {
      return response;
    } else {
      logError('Request Member Requests Response Failed', response.message);
      return null;
    }
  }

  Future<int> getMemberRequestsCount(forumId) async {
    final response = await Api.getMemberRequestsCount(forumId);
    if (response.success) {
      return response.data['count'] ?? 0;
    } else {
      logError('Request Member Requests Count Failed', response.message);
      return 0;
    }
  }

  Future<ResultApiModel?> acceptMemberRequests(
    forumId,
    memberRequestId,
    cityId,
  ) async {
    Map<String, dynamic> params = {
      "accept": true,
    };
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.acceptMemberRequests(
        forumId, cityId == 0 ? cityIdPref : cityId, memberRequestId, params);
    if (response.success) {
      return response;
    } else {
      logError(
          'Request Accept Member Requests Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> rejectMemberRequests(
      forumId, memberRequestId, reason, cityId) async {
    Map<String, dynamic> params = {
      "accept": false,
      "reason": reason,
    };
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.rejectMemberRequests(
        forumId, cityId == 0 ? cityIdPref : cityId, memberRequestId, params);
    if (response.success) {
      return response;
    } else {
      logError(
          'Request Reject Member Requests Response Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> requestMakeUserAdmin(forumId, memberId) async {
    final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    final Map<String, dynamic> params = {"isAdmin": 1};
    final response =
        await Api.requestMakeUserAdmin(cityId, forumId, memberId, params);
    if (response.success) {
      return response;
    } else {
      logError('Request make User Admin Failed', response.message);
      return null;
    }
  }

  Future<bool> requestRemoveAdmin(forumId, memberId, cityId) async {
    final prefCityId = prefs.getKeyValue(Preferences.cityId, 0);
    final Map<String, dynamic> params = {"isAdmin": 0};
    final response = await Api.requestRemoveAdmin(
        cityId == 0 ? prefCityId : cityId, forumId, memberId, params);
    if (response.success) {
      return true;
    } else {
      logError('Request Remove User Admin Failed', response.message);
      return false;
    }
  }

  Future<List<RequestMemberModel>?> getGroupMemberRequests() async {
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    final requestMemberList = <RequestMemberModel>[];
    final response = await Api.getGroupMemberRequests(userId);
    if (response.success) {
      for (final list in response.data) {
        requestMemberList.add(RequestMemberModel(
          forumId: list['forumId'],
          userId: list['userId'],
          statusId: list['statusId'],
          createdAt: list['createdAt'],
          updatedAt: list['updatedAt'],
          id: list['id'],
          reason: list['reason'],
        ));
      }
      return requestMemberList;
    } else {
      logError(
          'Request To Get Group Members Response Failed', response.message);
    }
    return null;
  }

  static Future<ResultApiModel?> uploadImage(File image, forumGroup) async {
    final prefs = await Preferences.openBox();
    List<String> parts = image.path.split('.');
    String imageExtension = parts.last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path,
          filename: image.path,
          contentType: MediaType('image', imageExtension)),
    });
    if (forumGroup) {
      await prefs.setPickedFile(formData);
    }
    return null;
  }

  Future<bool> deleteUserList(int? cityId, int listingId) async {
    final response = await Api.deleteUserList(cityId, listingId);
    if (response.success) {
      return true;
    } else {
      logError('Remove UserList Response Failed', response.message);
      return false;
    }
  }

  Future<void> deleteImage(cityId, listingId) async {
    await Api.deleteImage(cityId, listingId);
  }

  Future<ProductModel?> loadProduct(cityId, id) async {
    final response = await Api.requestProduct(cityId, id);
    if (response.success) {
      UtilLogger.log('ErrorReason', response.data);
      return ProductModel.fromJson(response.data, setting: Application.setting);
    } else {
      logError('Product Request Response', response.message);
    }
    return null;
  }

  void clearCityId() async {
    prefs.deleteKey(Preferences.cityId);
  }

  Future<void> clearImagePath() async {
    prefs.deleteKey(Preferences.path);
  }

  Future<ResultApiModel> loadForumCities() async {
    final response = await Api.requestCities();
    return response;
  }

  Future<ResultApiModel> saveForum(
    String title,
    String description,
    List<int> cityIds,
    String? type,
    String? selectedImagePath,
  ) async {
    final image = prefs.getKeyValue(Preferences.path, null);
    bool isPrivate = false;
    if (type == 'public') {
      isPrivate = false;
    } else if (type == 'private') {
      isPrivate = true;
    }

    Map<String, dynamic> params = {
      "cityIds": cityIds,
      "description": description,
      "forumName": title,
      "image": image,
      "isPrivate": isPrivate,
      "removeImage": false,
      "villageId": 0,
      "visibility": "",
    };
    FormData? pickedFile = await _getPickedImageFormData(selectedImagePath);
    final response = await Api.requestSaveForum(params);
    if (response.success) {
      final forumId = response.id;
      if (pickedFile != null) {
        await Api.requestForumImageUpload(forumId, pickedFile);
      }
      prefs.deleteKey('pickedFile');
      _ensureUserPublicKey(isNewGroup: true);
    }
    return response;
  }

  Future<ResultApiModel?> requestDeleteForum(
    forumId,
    cityId,
  ) async {
    int cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.requestDeleteForum(
        cityId == 0 ? cityIdPref : cityId, forumId);
    if (response.success) {
      handleGroupChatSubscription(forumId, false);
      return response;
    } else {
      logError('Delete Forum Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel> editForum(
    String title,
    String description,
    String? type,
    String? selectedImagePath,
    forumId,
    String createdDate,
  ) async {
    final image = prefs.getKeyValue(Preferences.path, null);
    bool isPrivate = false;
    if (type == 'public') {
      isPrivate = false;
    } else if (type == 'private') {
      isPrivate = true;
    }

    Map<String, dynamic> params = {
      "id": forumId,
      "forumName": title,
      "createdAt": createdDate,
      "description": description,
      "image": image,
      "isPrivate": isPrivate,
    };
    final response = await Api.requestEditForum(forumId, params);
    if (response.success) {
      if (selectedImagePath != null) {
        final prefs = await Preferences.openBox();
        FormData? pickedFile = await _getPickedImageFormData(selectedImagePath);
        if (pickedFile != null) {
          await Api.requestForumImageUpload(forumId, pickedFile);
        }
      }
      prefs.deleteKey('pickedFile');
    }
    return response;
  }

  Future<ResultApiModel> savePost(
    String title,
    String description,
    int? cityId,
    int? forumId,
  ) async {
    final image = prefs.getKeyValue(Preferences.path, null);
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);

    Map<String, dynamic> params = {
      "cityId": cityId == 0 ? cityIdPref : cityId,
      "description": description,
      "title": title,
      "image": image,
    };
    final response = await Api.requestSavePost(
        cityId == 0 ? cityIdPref : cityId, forumId, params);
    if (response.success) {
      final postId = response.id;
      final prefs = await Preferences.openBox();
      FormData? pickedFile = prefs.getPickedFile();
      if (pickedFile != null) {
        await Api.requestPostImageUpload(
            cityId == 0 ? cityIdPref : cityId, forumId, postId, pickedFile);
      }
      prefs.deleteKey('pickedFile');
    }
    return response;
  }

  Future<void> setImagePrefs(imagePath) async {
    await prefs.setKeyValue(Preferences.path, imagePath);
  }

  Future<int> getCityId(cityName) async {
    final response = await Api.requestSubmitCities();
    var jsonCategory = response.data;
    final item = jsonCategory.firstWhere((item) => item['name'] == cityName);
    final itemId = item['id'];
    final cityId = itemId;
    return cityId;
  }

  Future<int> getCategoryId() async {
    return await prefs.getKeyValue(Preferences.categoryId, 0);
  }

  Future<List<CommentModel>> getPostComments(
      int forumId, int postId, page, cityId) async {
    int cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.requestPostComments(
        cityId != 0 ? cityId : cityIdPref, forumId, postId, page);
    if (response.success) {
      final List<CommentModel> comments = [];
      for (final jsonComment in response.data) {
        final comment = CommentModel.fromJson(jsonComment);
        comments.add(comment);
      }
      return comments;
    } else {
      logError('Get Post Comments Failed', response.message);
      return [];
    }
  }

  Future<ResultApiModel> addPostComments(
      int forumId, int postId, String comment, cityId) async {
    int cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    Map<String, dynamic> params = {
      "comment": comment,
    };
    final response = await Api.addPostComments(
        cityId != 0 ? cityId : cityIdPref, forumId, postId, params);
    if (response.success) {
      return response;
    } else {
      logError('Add Post Comment Failed', response.message);
      return response;
    }
  }

  Future<ResultApiModel> addPostCommentsReply(
      int forumId, int postId, String comment, int parentId, cityId) async {
    int cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    Map<String, dynamic> params = {
      "comment": comment,
      "parentId": parentId,
    };
    final response = await Api.addPostComments(
        cityId != 0 ? cityId : cityIdPref, forumId, postId, params);
    if (response.success) {
      return response;
    } else {
      logError('Get Post Comments Reply Failed', response.message);
      return response;
    }
  }

  Future<List<CommentModel>> getPostCommentsReplies(
      int forumId, int postId, int parentId, int pageNo, cityId) async {
    int cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);
    final response = await Api.requestPostCommentsReplies(
        cityId != 0 ? cityId : cityIdPref, forumId, postId, parentId, pageNo);
    if (response.success) {
      final List<CommentModel> replies = [];
      for (final jsonReply in response.data) {
        final reply = CommentModel.fromJson(jsonReply);
        replies.add(reply);
      }
      return replies;
    } else {
      logError('Get Comment Replies Failed', response.message);
      return [];
    }
  }

  Future<void> handleGroupChatSubscription(int forumId, bool subscribe) async {
    final prefs = await Preferences.openBox();
    int cityId = prefs.getKeyValue(Preferences.cityId, 0);

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final firebaseApi = FirebaseMessagingService(navigatorKey, prefs);
    // final topic = "groupChat_city_${cityId}_forum_$forumId";
    final topic = "groupChat_forum_$forumId";

    List<String> forumChatTopics = prefs.getForumChatTopics();

    if (subscribe) {
      await firebaseApi.subscribeToTopic(topic);

      if (!forumChatTopics.contains(topic)) {
        forumChatTopics.add(topic);
        await prefs.setForumChatTopics(forumChatTopics);
      }
    } else {
      await firebaseApi.unsubscribeFromTopic(topic);

      if (forumChatTopics.contains(topic)) {
        forumChatTopics.remove(topic);
        await prefs.setForumChatTopics(forumChatTopics);
      }
    }
  }

  Future<FormData?> _getPickedImageFormData(String? selectedImagePath) async {
    if (selectedImagePath == null) {
      return null;
    }
    List<String> parts = selectedImagePath.split('.');
    String imageExtension = parts.last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(selectedImagePath,
          filename: selectedImagePath,
          contentType: MediaType('image', imageExtension)),
    });
    return formData;
  }

  Future<ResultApiModel?> sendReaction(
      {required int forumId,
      required int messageId,
      required int reaction}) async {
    final response = await Api.sendReactionForForum(
        forumId: forumId, messageId: messageId, reaction: reaction);

    if (response.success) {
      return response;
    } else {
      logError('Send Reaction Failed', response.message);
      return null;
    }
  }

  Future<ResultApiModel?> deleteReaction(
      {required int forumId, required int messageId}) async {
    // Delete reaction for a message
    final response = await Api.deleteReactionForForum(
        forumId: forumId, messageId: messageId);

    if (response.success) {
      return response;
    } else {
      logError('Delete Reaction Failed', response.message);
      return null;
    }
  }
}
