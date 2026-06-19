import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_notificaiton_preference_update.dart';
import 'package:your_app_name/src/data/remote/api/http_manager.dart';
import 'package:your_app_name/src/utils/asset.dart';
import 'package:your_app_name/src/utils/common.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/network/network_service.dart';

class Api {
  static const String login = "/users/login";
  static const String user = "/users/";
  static const String register = "/users/register";
  static const String forgotPassword = "/users/forgotPassword";
  static const String changePassword = "/users/resetPassword";
  static const String categories = "/categories";
  static const String categoriesCount = "/categories/listingsCount";
  static const String list = "/listings";
  static const String cities = "/cities";
  static const String listings = "/listings?statusId=1";
  static const String contact = "/contactUs";
  static const String faq = "/moreInfo";
  static const String hasForum = "/cities?hasForum=true";
  static const bool showExternalListings = true;

  static Future<ResultApiModel> requestLogin(params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: login, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestRefreshToken(userId, params) async {
    final result = await HTTPManager(forum: false)
        .post(url: 'users/$userId/refresh', data: params);

    return ResultApiModel.fromJson(result);
  }

  ///Logout user
  static Future<ResultApiModel> requestLogout(userId, params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: 'users/$userId/logout',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestFavorites(userId) async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: 'users/$userId/favorites?pageNo=1&pageSize=19',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestUserListings(userId, pageNo) async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path:
            'users/$userId/listings?pageNo=$pageNo&pageSize=5&showExternalListings=$showExternalListings',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestMyListings(pageNo) async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: 'users/myListings', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestForum(cityId, pageNo) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: '/forums/?cityId=$cityId&pageNo=$pageNo&pageSize=10',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestForumStatus(
      userId, cityId, forumIds) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'users/$userId/checkMembership?forumIds=$forumIds',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestUsersForum(userId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'users/$userId/forums?statusId=1',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getGroupMemberRequests(userId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'users/$userId/memberRequests', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  // static Future<ResultApiModel> requestToJoinGroup(forumId, cityId) async {
  //   final filepath = "forums/$forumId/memberRequests";
  //   final result = await HTTPManager(forum: true).post(url: filepath);
  //   return ResultApiModel.fromJson(result);
  // }

  static Future<ResultApiModel> requestToJoinGroup(
      forumId, cityId, params) async {
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: 'forums/$forumId/memberRequests',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestGroupDetails(forumId, cityId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'forums/$forumId', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> removeUserFromGroup(
      forumId, cityId, memberId) async {
    final result = await NetworkService()
        .forumApi
        .deleteRequest<ResultApiModel>(
            path: 'forums/$forumId/members/$memberId',
            create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestGroupPosts(forumId, cityId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'forums/$forumId/posts', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deleteGroupPost(forumId, cityId, postId) async {
    final result = await NetworkService()
        .forumApi
        .deleteRequest<ResultApiModel>(
            path: 'forums/$forumId/posts/$postId',
            create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> uploadToken(userId, params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: 'users/$userId/storeFirebaseUserToken',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> reportGroupPosts(
      forumId, cityId, postId, params) async {
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: 'forums/$forumId/posts/$postId/reports',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getGroupMembers(forumId, cityId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'forums/$forumId/members', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getMemberRequests(forumId, cityId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'forums/$forumId/memberRequests?statusId=1',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getMemberRequestsCount(forumId) async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: 'forums/$forumId/member-requests/count',
        create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> acceptMemberRequests(
      forumId, cityId, memberRequestId, params) async {
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: 'forums/$forumId/memberRequests/$memberRequestId',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> rejectMemberRequests(
      forumId, cityId, memberRequestId, params) async {
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: 'forums/$forumId/memberRequests/$memberRequestId',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestMakeUserAdmin(
      cityId, forumId, memberId, params) async {
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: 'forums/$forumId/members/$memberId',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestRemoveAdmin(
      cityId, forumId, memberId, params) async {
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: 'forums/$forumId/members/$memberId',
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestHasForum() async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: hasForum, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestFavoritesDetailsList(
      cityId, listingId) async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: 'listings/$listingId', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestForgotPassword(params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: forgotPassword, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Register account
  static Future<ResultApiModel> requestRegister(params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: register, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Change Profile
  static Future<ResultApiModel> requestChangeProfile(params, userId) async {
    final filePath = 'users/$userId';
    final result = await NetworkService().baseApi.patchRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///change password
  static Future<ResultApiModel> requestChangePassword(params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: changePassword,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestUser({required userId}) async {
    final filePath = 'users/$userId';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getUserDetails(userId, cityId) async {
    final filePath = 'users/$userId?cityId=$cityId&cityUser=true';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Category
  static Future<ResultApiModel> requestCategory(params) async {
    final result = await UtilAsset.loadJson("assets/data/category.json");
    // final result = await HTTPManager(forum: false).get(url: categories, params: params);
    return ResultApiModel.fromJson(result);
  }

  static Future<ResultApiModel> requestSubmitCategory() async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: categories, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestSubmitSubCategory(
      {required categoryId}) async {
    final filePath = 'categories/$categoryId/subcategories';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestCategoryCount(int? cityId) async {
    String url = categoriesCount;
    if (cityId != null) {
      url = "$url?cityId=$cityId";
    }
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: url, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Home Categories
  static Future<ResultApiModel> requestHomeCategory() async {
    final result = await UtilAsset.loadJson("assets/data/category.json");
    // final result = await HTTPManager(forum: false).get(url: categories);
    return ResultApiModel.fromJson(result);
  }

  ///Get Cities
  static Future<ResultApiModel> requestCities() async {
    // final result = await UtilAsset.loadJson("assets/data/locations.json");
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: cities, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestVillages({required cityId}) async {
    const filePath = '/villages';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Submit Cities
  static Future<ResultApiModel> requestSubmitCities() async {
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: cities, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Recent Listings
  static Future<ResultApiModel> requestRecentListings(params) async {
    final listings =
        "/listings?statusId=1&pageNo=$params&pageSize=19&showExternalListings=$showExternalListings";
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: listings, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get All Listings
  static Future<ResultApiModel> requestAllListings(params) async {
    final listings =
        "/listings?pageNo=$params&pageSize=10&showExternalListings=$showExternalListings";
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: listings, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Listings by status
  static Future<ResultApiModel> requestStatusListings(status, params) async {
    final listings =
        "/listings?statusId=$status&pageNo=$params&pageSize=10&showExternalListings=$showExternalListings";
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: listings, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get pending listings count for admin
  static Future<ResultApiModel> requestPendingListingsCount() async {
    const listings = "/listings/pending/count";
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: listings, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Listings by status and location
  static Future<ResultApiModel> requestStatusLocList(
      params, pageNo, status) async {
    var list =
        '/listings?cityId=$params&statusId=$status&pageNo=$pageNo&pageSize=19';
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Home Slider Images
  static Future<ResultApiModel> requestSliderImages() async {
    final result = await UtilAsset.loadJson("assets/data/sliders.json");
    return ResultApiModel.fromJson(result);
  }

  ///Get ProductDetail
  static Future<ResultApiModel> requestProduct(cityId, id) async {
    final filePath = '/listings/$id';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Save Wish List
  static Future<ResultApiModel> requestAddWishList(userId, params) async {
    final String addWishList = "/users/$userId/favorites/";
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: addWishList, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Save Product
  static Future<ResultApiModel> requestSaveProduct(
      cityId, params, isImageChanged) async {
    const filePath = '/listings';
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Save Forum
  static Future<ResultApiModel> requestSaveForum(params) async {
    const filePath = '/forums';
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestEditForum(id, params) async {
    final filePath = '/forums/$id/';
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params,
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestDeleteForum(cityId, id) async {
    final filePath = '/forums/$id/';
    final result = await NetworkService()
        .forumApi
        .deleteRequest<ResultApiModel>(
            path: filePath, create: () => ResultApiModel(), loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Save Post
  static Future<ResultApiModel> requestSavePost(cityId, fId, params) async {
    final filePath = '/forums/$fId/posts';
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestEditProduct(
      cityId, listingId, params, bool isImageChanged) async {
    final filePath = '/listings/$listingId';
    final result = await NetworkService().baseApi.patchRequest<ResultApiModel>(
        path: filePath, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestEditProductStatus(
    cityId,
    listingId,
    params,
  ) async {
    final filePath = '/listings/$listingId';
    final result = await NetworkService().baseApi.patchRequest<ResultApiModel>(
        path: filePath,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Remove Wish List
  static Future<ResultApiModel> requestRemoveWishList(
      userId, int listingId) async {
    final String removeWishList = "/users/$userId/favorites/$listingId";
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: removeWishList, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deletePdf(cityId, listingId) async {
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: '/listings/$listingId/pdfDelete',
        create: () => ResultApiModel(),
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deleteImage(cityId, listingId) async {
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: '/listings/$listingId/imageDelete',
        create: () => ResultApiModel(),
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deleteProfileImage(userId) async {
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: '/users/$userId/imageDelete',
        create: () => ResultApiModel(),
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deleteUserList(cityId, int listingId) async {
    final String removeList = "/listings/$listingId";
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: removeList, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get Product List
  static Future<ResultApiModel> requestCatList(params, cityId, pageNo,
      {String? eventType, String? startDate, String? endDate}) async {
    if (params == 3) {
      if (cityId != 0 && cityId != null) {
        var list =
            '/listings?categoryId=$params&statusId=1&pageNo=$pageNo&pageSize=19&sortByStartDate=true&cityId=$cityId&showExternalListings=$showExternalListings';

        if (eventType != null && eventType.isNotEmpty) {
          list += '&eventType=$eventType';
        }

        if (startDate != null && startDate.isNotEmpty) {
          list += '&startAfterDate=$startDate';
        }

        if (endDate != null && endDate.isNotEmpty) {
          list += '&endBeforeDate=$endDate';
        }

        final result = await NetworkService()
            .baseApi
            .getRequest<ResultApiModel>(
                path: list, create: () => ResultApiModel(), loading: true);
        return result.fold(
            (l) =>
                ResultApiModel(successValue: false, messageValue: l.toString()),
            (r) => r);
      } else {
        var list =
            '/listings?categoryId=$params&statusId=1&pageNo=$pageNo&pageSize=19&sortByStartDate=true&showExternalListings=$showExternalListings';

        if (eventType != null && eventType.isNotEmpty) {
          list += '&eventType=$eventType';
        }

        if (startDate != null && startDate.isNotEmpty) {
          list += '&startAfterDate=$startDate';
        }

        if (endDate != null && endDate.isNotEmpty) {
          list += '&endBeforeDate=$endDate';
        }

        final result = await NetworkService()
            .baseApi
            .getRequest<ResultApiModel>(
                path: list, create: () => ResultApiModel());
        return result.fold(
            (l) =>
                ResultApiModel(successValue: false, messageValue: l.toString()),
            (r) => r);
      }
    } else {
      if (cityId != 0 && cityId != null) {
        var list =
            '/listings?categoryId=$params&statusId=1&pageNo=$pageNo&pageSize=19&cityId=$cityId&showExternalListings=$showExternalListings';
        final result = await NetworkService()
            .baseApi
            .getRequest<ResultApiModel>(
                path: list, create: () => ResultApiModel());
        return result.fold(
            (l) =>
                ResultApiModel(successValue: false, messageValue: l.toString()),
            (r) => r);
      } else {
        var list =
            '/listings?categoryId=$params&statusId=1&pageNo=$pageNo&pageSize=19&showExternalListings=$showExternalListings';
        final result = await NetworkService()
            .baseApi
            .getRequest<ResultApiModel>(
                path: list, create: () => ResultApiModel());
        return result.fold(
            (l) =>
                ResultApiModel(successValue: false, messageValue: l.toString()),
            (r) => r);
      }
    }
  }

  static Future<ResultApiModel> requestSubCatList(params, pageNo) async {
    var list =
        '/listings?subCategoryId=10&categoryId=1&statusId=1&pageNo=$pageNo&pageSize=19&showExternalListings=$showExternalListings';
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestLocList(params, pageNo) async {
    var list =
        '/listings?cityId=$params&statusId=1&pageNo=$pageNo&pageSize=19&showExternalListings=$showExternalListings';
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> contactUs(params) async {
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: contact,
        create: () => ResultApiModel(),
        body: params,
        loading: true);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestUploadImage(formData) async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, '');
    var filepath = '/users/$userId/imageUpload';

    final result =
        await NetworkService().baseApi.postFormRequest<ResultApiModel>(
              path: filepath,
              create: () => ResultApiModel(),
              body: formData,
              isConvertResponse: true,
            );

    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<void> requestListingUploadMedia(
      listingId, cityId, pickedFile) async {
    var filePath = '';

    if (pickedFile?.files.length != 0) {
      var firstFileEntry = pickedFile?.files[0];
      if (firstFileEntry?.key == 'pdf') {
        filePath = '/listings/$listingId/pdfUpload';
      } else if (firstFileEntry?.key == 'image') {
        filePath = '/listings/$listingId/imageUpload';
      }

      final result= await NetworkService().baseApi.postFormRequest<ResultApiModel>(
            path: filePath,
            create: () => ResultApiModel(),
            body: pickedFile,
          );
      return result.fold(
              (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
              (r) => r);
    }
  }

  static Future<ResultApiModel> requestForumImageUpload(
      forumId, pickedFile) async {
    var filePath = '';
    filePath = '/forums/$forumId/imageUpload';

    final result =
        await NetworkService().forumApi.postFormRequest<ResultApiModel>(
              path: filePath,
              create: () => ResultApiModel(),
              body: pickedFile,
              isConvertResponse: true,
            );

    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestPostImageUpload(
      cityId, forumId, postId, pickedFile) async {
    var filePath = '';
    filePath = '/forums/$forumId/posts/$postId/imageUpload';

    final result =
        await NetworkService().forumApi.postFormRequest<ResultApiModel>(
              path: filePath,
              create: () => ResultApiModel(),
              body: pickedFile,
              isConvertResponse: true,
            );

    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> deleteUserAccount(userId) async {
    final String deleteAccount = "/users/$userId";
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
        path: deleteAccount, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestPostComments(
      cityId, forumId, postId, page) async {
    var list =
        '/forums/$forumId/posts/$postId/comments?pageNo=$page&pageSize=19';
    final result = await NetworkService()
        .forumApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> addPostComments(
      cityId, forumId, postId, params) async {
    var list = '/forums/$forumId/posts/$postId/comments';
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: list, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> addPostCommentsReply(
      cityId, forumId, postId, params) async {
    var list = '/forums/$forumId/posts/$postId/comments';
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: list, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestPostCommentsReplies(
      cityId, forumId, postId, parentId, pageNo) async {
    var list =
        '/forums/$forumId/posts/$postId/comments?pageNo=$pageNo&pageSize=19&parentId=$parentId';
    final result = await NetworkService()
        .forumApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> moreInfo() async {
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: faq, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestSearchListing(
      content, filter, pageNo) async {
    var list =
        '/listings/search?searchQuery=$content$filter&pageNo=$pageNo&pageSize=10';
    final result = await NetworkService()
        .baseApi
        .getRequest<ResultApiModel>(path: list, create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getForumKeys(
      {required int forumId,
      required int userId,
      required int cityId,
      required Map<String, dynamic> params}) async {
    final String filepath = "/forums/$forumId/members/get-forum-keys";
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: filepath, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> updateForumKeys(
      {required Map<String, dynamic> params}) async {
    const String filepath = "/users/update-key";
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: filepath, create: () => ResultApiModel(), body: params);
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Get all groups list with status for admin
  static Future<ResultApiModel> getAllGroups() async {
    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
        path: '/forums/listings', create: () => ResultApiModel());
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> changeStatusOfForum({
    required int forumId,
    required int status,
  }) async {
    final result = await NetworkService().forumApi.patchRequest<ResultApiModel>(
        path: '/forums/$forumId/status',
        create: () => ResultApiModel(),
        body: {"status": status});
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getForumChatMessages(
      {required int forumId,
      required int cityId,
      required int? lastMessageId,
      required int offset}) async {
    String filepath = "/forums/$forumId/chat?pageNo=$offset&pageSize=15";

    if (lastMessageId != null && lastMessageId > 0) {
      filepath += "&lastMessageId=$lastMessageId";
    }

    final result = await NetworkService().forumApi.getRequest<ResultApiModel>(
          path: filepath,
          create: () => ResultApiModel(),
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> sendChatMessage(
      {required int forumId, required FormData forumData}) async {
    final String filepath = "/forums/$forumId/chat";
    final result =
        await NetworkService().forumApi.postFormRequest<ResultApiModel>(
              path: filepath,
              create: () => ResultApiModel(),
              body: forumData,
            );

    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getChatMessagesForPost({
    required int listingId,
    int? pageNo,
    int? pageSize,
    bool isReversed = false,
  }) async {
    final String filepath = "/listings/$listingId/chat";
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
        path: filepath,
        create: () => ResultApiModel(),
        params: {
          if (pageNo != null) "pageNo": pageNo,
          if (pageSize != null) "pageSize": pageSize,
          "isReversed": isReversed,
        });
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> sendChatMessagesForPost({
    required int listingId,
    required String message,
    int? parentMessageId,
    File? file,
  }) async {
    final String filepath = "/listings/$listingId/chat";

    final formData = FormData.fromMap({
      if (message.isNotEmpty) 'message': message,
      if (parentMessageId != null) 'parentId': parentMessageId.toString(),
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          contentType: Utils().getMediaType(file.path),
          filename: file.path.split(Platform.pathSeparator).last,
        ),
    });
    final result =
        await NetworkService().baseApi.postFormRequest<ResultApiModel>(
              path: filepath,
              create: () => ResultApiModel(),
              body: formData,
            );

    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static sendReactionForMessage(
      {required int listingId,
      required int messageId,
      required int reaction}) async {
    final String filepath = "/listings/$listingId/chat/$messageId/react";
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
        path: filepath,
        create: () => ResultApiModel(),
        body: {"reaction": reaction});
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static deleteReaction(
      {required int listingId, required int messageId}) async {
    final String filepath = "/listings/$listingId/chat/$messageId/react";
    final result = await NetworkService().baseApi.deleteRequest<ResultApiModel>(
          path: filepath,
          create: () => ResultApiModel(),
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static sendReactionForForum(
      {required int forumId,
      required int messageId,
      required int reaction}) async {
    final String filepath = "/forums/$forumId/chat/$messageId/react";
    final result = await NetworkService().forumApi.postRequest<ResultApiModel>(
        path: filepath,
        create: () => ResultApiModel(),
        body: {"reaction": reaction});
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static deleteReactionForForum(
      {required int forumId, required int messageId}) async {
    final String filepath = "/forums/$forumId/chat/$messageId/react";
    final result =
        await NetworkService().forumApi.deleteRequest<ResultApiModel>(
              path: filepath,
              create: () => ResultApiModel(),
            );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestPatchNotificationPreference(
      userId, ModelNotificationPreferenceUpdateRequest params) async {
    final filePath = '/users/$userId/notificationPreference';
    final result = await NetworkService().baseApi.patchRequest<ResultApiModel>(
          path: filePath,
          create: () => ResultApiModel(),
          body: params.toJson(),
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> requestPostNotificationPreference(
      userId, ModelNotificationPreferenceUpdateRequest params) async {
    final filePath = '/users/$userId/notificationPreference';
    final result = await NetworkService().baseApi.postRequest<ResultApiModel>(
          path: filePath,
          create: () => ResultApiModel(),
          body: params.toJson(),
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  static Future<ResultApiModel> getNotificationPreferences(
    userId,
  ) async {
    final filePath = '/users/$userId/notificationPreference';
    final result = await NetworkService().baseApi.getRequest<ResultApiModel>(
          path: filePath,
          create: () => ResultApiModel(),
        );
    return result.fold(
        (l) => ResultApiModel(successValue: false, messageValue: l.toString()),
        (r) => r);
  }

  ///Singleton factory
  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  Api._internal();
}
