import 'dart:convert';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/services/firebase_token_manager.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  await Hive.initFlutter();
  final prefs = await Preferences.openBox();
  int currentBadgeCount = prefs.getKeyValue(Preferences.badgeCount, 0) ?? 0;
  currentBadgeCount++;
  await prefs.setKeyValue(Preferences.badgeCount, currentBadgeCount);
  if (await AppBadgePlus.isSupported()) {
    AppBadgePlus.updateBadge(currentBadgeCount);
  }
}

class FirebaseMessagingService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  final Preferences prefs;
  final _firebaseTokenManager = FirebaseTokenManager();

  FirebaseMessagingService(this.navigatorKey, this.prefs);
  // Helper method to dismiss existing dialog and show notification dialog
  void _showNotificationDialog(
      BuildContext context, String title, String body, RemoteMessage message) {
    // Dismiss any existing dialogs to prevent stacking
    Navigator.of(context, rootNavigator: true).popUntil((route) {
      return route.isFirst || route.settings.name != null;
    });

    // Show the new notification dialog
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            child: const Text("Open"),
            onPressed: () {
              Navigator.pop(context);
              handleMessageOnUserInteraction(message);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Dismiss"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> handleMessageOnUserInteraction(RemoteMessage? message) async {
    if (await AppBadgePlus.isSupported()) {
      AppBadgePlus.updateBadge(0);
      await prefs.setKeyValue(Preferences.badgeCount, 0);
    }
    if (message != null) {
      final notificationType = message.data["type"];
      
      // Get current route name for navigation decision
      String? currentRoute;
      navigatorKey.currentState?.popUntil((route) {
        currentRoute = route.settings.name;
        return true;
      });
      
      if (message.data["forumId"] != null && notificationType == "forum_chat") {
        /// if we are navigating to group chat
        final Map<String, dynamic> forumData =
            jsonDecode(message.data['forumData']);
        if (message.data['cityIds'] != null) {
          forumData['cityIds'] = jsonDecode(message.data['cityIds']);
        }
        final ForumGroupModel forumGroupModel =
            ForumGroupModel.fromJson(forumData);

        // Use pushReplacementNamed if currently on any chat screen
        if (currentRoute == Routes.groupChat || currentRoute == Routes.chat) {
          navigatorKey.currentState?.pushReplacementNamed(
            Routes.groupChat,
            arguments: {'group': forumGroupModel},
          );
        } else {
          navigatorKey.currentState?.pushNamed(
            Routes.groupChat,
            arguments: {'group': forumGroupModel},
          );
        }
      } else if ((message.data["listingId"] != null &&
          notificationType == "listing_chat" )
          ||(int.parse(message.data["status"]) == 3
              && notificationType == "listing_status_update")) {
        final int listingId = int.parse(message.data["listingId"]);
        
        // Use pushReplacementNamed if currently on any chat screen
        if (currentRoute == Routes.groupChat || currentRoute == Routes.chat) {
          navigatorKey.currentState?.pushReplacementNamed(
            Routes.chat,
            arguments: {'isAdmin': false, 'listingId': listingId},
          );
        } else {
          navigatorKey.currentState?.pushNamed(
            Routes.chat,
            arguments: {'isAdmin': false, 'listingId': listingId},
          );
        }
      } else if (message.data["id"] != null) {
        final item =
            await ListRepository.loadProduct(0, int.parse(message.data["id"]));
        if (item != null) {
          navigatorKey.currentState
              ?.pushNamed(Routes.productDetail, arguments: item);
        }
      }
    }
  }

  Future<void> handleForegroundNotification(RemoteMessage message) async {
    logInfo("Foreground notification received: ${message.notification?.title}");
    int currentBadgeCount = prefs.getKeyValue(Preferences.badgeCount, 0) ?? 0;
    currentBadgeCount++;
    await prefs.setKeyValue(Preferences.badgeCount, currentBadgeCount);
    if (await AppBadgePlus.isSupported()) {
      AppBadgePlus.updateBadge(currentBadgeCount);
    }

    // Check if user is already on the target screen based on notification type
    final context = navigatorKey.currentState?.context;

    print("remote message data: ${message.data.toString()}");
    print("remote message senderID: ${message.senderId.toString()}");
    print("remote message notification: ${message.notification.toString()}");

    int senderId= int.parse(message.data['sender']??"-1");


    if (context != null
        && message.notification != null
        && ( senderId !=prefs.getKeyValue(Preferences.userId, 0))) {
      bool shouldShowDialog = true;

      try {
        // Get current route name and arguments with null safety
        String? currentRoute;
        Map<String, dynamic>? routeArgs;
        navigatorKey.currentState?.popUntil((route) {
          currentRoute = route.settings.name;

          routeArgs = route.settings.arguments as Map<String, dynamic>?;
          return true;
        });
        logInfo("Current route: '$currentRoute'");

        // Don't interrupt listing creation/success flow with notification dialogs
        if (currentRoute == Routes.submit ||
            currentRoute == Routes.submitSuccess) {
          return;
        }

        final notificationType = message.data["type"];
        logInfo("Notification type: '$notificationType'");
        if (notificationType == "listing_chat") {
          // Check if user is already on the chat screen for this listing
          if (currentRoute == Routes.chat) {
            shouldShowDialog = false;
          }
        } else if (notificationType == "forum_chat") {
          // Check if user is already on the forum groups screen for this city
          final senderId =
              int.tryParse(message.data['senderId']?.toString() ?? '');

          if (currentRoute == Routes.groupChat &&
              message.data["forumId"] != null ) {
            // final int forumId = int.parse(message.data["forumId"]);

            shouldShowDialog = false;
          }
        } else if (message.data["id"] != null) {
          // For other notification types (product details), check if user is on product detail screen
          if (currentRoute == Routes.productDetail) {
            final productId = int.parse(message.data["id"]);
            if (routeArgs != null) {
              // Check if the product model has the same id
              if (routeArgs?.containsKey('id') ?? false) {
                if (routeArgs?['id'] == productId) {
                  shouldShowDialog = false;
                }
              } else if (routeArgs.toString().contains('id: $productId')) {
                shouldShowDialog = false;
              }
            }
          }
        }

        // Only show dialog if user is not already on the target screen
        if (shouldShowDialog) {
          final title = message.notification!.title ?? '';
          final body = message.notification!.body ?? '';

          _showNotificationDialog(context, title, body, message);
        }
      } catch (e) {
        logInfo("Error processing foreground notification: $e");
        // Fallback: always show dialog if there's an error determining route
        final title = message.notification!.title ?? '';
        final body = message.notification!.body ?? '';

        _showNotificationDialog(context, title, body, message);
      }
    }
  }

  Future<void> initNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      prefs.setKeyValue(Preferences.pushNotificationsPermission, "authorized");
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      prefs.setKeyValue(Preferences.pushNotificationsPermission, "denied");
    }

    final pushNotificationsPermission =
        await prefs.getKeyValue(Preferences.pushNotificationsPermission, "0");
    final receiveNotification =
        await prefs.getKeyValue(Preferences.receiveNotification, "true");

    try {
      if (pushNotificationsPermission == "authorized" &&
          receiveNotification == "true") {
        await _subscribeToAllForumChats();
        await _firebaseMessaging.subscribeToTopic("warnings");
      } else {
        await _unsubscribeFromAllForumChats();
        await _firebaseMessaging.unsubscribeFromTopic("warnings");
      }
      // ignore: empty_catches
    } catch (e) {}

    await _firebaseTokenManager.fetchAndUploadToken();

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false, badge: false, sound: false);

    _firebaseMessaging.getInitialMessage().then(handleMessageOnUserInteraction);
    FirebaseMessaging.onMessage.listen(handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOnUserInteraction);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> refreshNotifications() async {
    final pushNotificationsPermission =
        await prefs.getKeyValue(Preferences.pushNotificationsPermission, "0");
    final receiveNotification =
        await prefs.getKeyValue(Preferences.receiveNotification, "true");

    if (pushNotificationsPermission == "authorized" &&
        receiveNotification == "true") {
      await _subscribeToAllForumChats();
      await _firebaseMessaging.subscribeToTopic("warnings");
    } else {
      await _unsubscribeFromAllForumChats();
      await _firebaseMessaging.unsubscribeFromTopic("warnings");
    }
  }

  Future<void> _unsubscribeFromAllForumChats() async {
    final List<String> forumChatTopics = await _getForumChatTopics();
    for (String topic in forumChatTopics) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      logInfo("Unsubscribed from forum chat topic: $topic");
    }
  }

  Future<void> _subscribeToAllForumChats() async {
    final List<String> forumChatTopics = await _getForumChatTopics();
    for (String topic in forumChatTopics) {
      await _firebaseMessaging.subscribeToTopic(topic);
      logInfo("Subscribed to forum chat topic: $topic");
    }
  }

  Future<List<String>> _getForumChatTopics() async {
    final prefs = await Preferences.openBox();
    final List<String>? forumChatTopics =
        prefs.getKeyValue(Preferences.forumChatTopics, <String>[]);
    return forumChatTopics ?? <String>[];
  }

  void unsubscribeFromAllForumChats() {
    _unsubscribeFromAllForumChats();
  }

  void subscribeToAllForumChats() {
    _subscribeToAllForumChats();
  }

  Future<void> onLogout() async {
    // Reset badge count
    if (await AppBadgePlus.isSupported()) {
      AppBadgePlus.updateBadge(0);
    }
    await prefs.setKeyValue(Preferences.badgeCount, 0);
    
    // Unsubscribe from all forum chat topics
    await _unsubscribeFromAllForumChats();
    
    // Unsubscribe from warnings topic
    await _firebaseMessaging.unsubscribeFromTopic("warnings");
    
    // Clear stored forum chat topics
    // await prefs.setKeyValue(Preferences.forumChatTopics, <String>[]);
    
    logInfo("User logged out - cleared notifications and unsubscribed from topics");
  }

}
