// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/group_details/cubit/group_details_cubit.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/group_details/cubit/group_details_state.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../../../services/remot_config_service.dart';
import '../../../../../widget/chat_widget/chat_input.dart';
import 'chat_messages/chat_message_list.dart';

class GroupChatScreen extends StatefulWidget {
  final bool isAdmin;

  const GroupChatScreen({super.key, required this.isAdmin});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) => state.maybeWhen(
        loading: () => const ChatLoading(),
        loaded: (list, group, isAdmin, userId, memberRequestCount) =>
            ChatLoaded(
          isSendingMessages: false,
          group: group,
          isAdmin: isAdmin,
          userId: userId,
          memberRequestCount: memberRequestCount,
        ),
        messagesLoaded: (messages, group, isAdmin, userId, replyTo,
                isLoadingMore, isSendingMessages, memberRequestCount) =>
            ChatLoaded(
          isSendingMessages: isSendingMessages ?? false,
          group: group,
          isAdmin: isAdmin,
          userId: userId,
          messages: messages,
          replyTo: replyTo,
          memberRequestCount: memberRequestCount,
        ),
        orElse: () => ErrorWidget("Failed to load chat."),
      ),
    );
  }
}

class ChatLoading extends StatelessWidget {
  const ChatLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ChatLoaded extends StatefulWidget {
  final bool isAdmin;
  final int userId;
  final ForumGroupModel group;
  final List<ChatMessageModel>? messages;
  final ChatMessageModel? replyTo;
  final bool isSendingMessages;
  final int? memberRequestCount;

  const ChatLoaded({
    super.key,
    required this.isAdmin,
    required this.userId,
    required this.group,
    this.messages,
    this.replyTo,
    required this.isSendingMessages,
    this.memberRequestCount,
  });

  @override
  State<ChatLoaded> createState() => _ChatLoadedState();
}

class _ChatLoadedState extends State<ChatLoaded> {
  WebSocketChannel? channel;
  StreamSubscription? _channelSubscription;
  Timer? pingTimer;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  int _unreadMessageCount = 0;
  bool _showNewMessageBanner = false;
  bool isLoading = false;
  Timer? _bannerTimer;
  int _messageCount = 0; // Counter for incoming WebSocket messages

  // Message queue to prevent race conditions
  final List<Map<String, dynamic>> _messageQueue = [];
  bool _isProcessingQueue = false;
  Timer? _queueProcessor;

  @override
  void initState() {
    super.initState();
    _fetchMessages(isInitialLoad: true);
    _connectWebsocket(widget.group.cityId ?? 1, widget.group.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _channelSubscription?.cancel();
    channel?.sink.close();
    if (pingTimer != null) {
      pingTimer?.cancel();
    }
    if (_bannerTimer != null) {
      _bannerTimer?.cancel();
    }
    if (_queueProcessor != null) {
      _queueProcessor?.cancel();
    }
    _scrollController.removeListener(_onScroll); // Remove the scroll listener
    _scrollController.dispose();
    _inputFocusNode.dispose();
    // context.read<GroupDetailsCubit>().resetOffset();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrolledToBottom()) {
      // Reset the unread message count when scrolled to bottom
      setState(() {
        _unreadMessageCount = 0;
      });
    }
  }

  bool _isScrolledToBottom() {
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent;
  }

  Future<void> _connectWebsocket(int? cityId, int? forumId) async {
    final config = RemoteConfigService();
    final wsUrl = Uri.parse(config.wsUrl);
    channel = WebSocketChannel.connect(wsUrl);

    try {
      await channel?.ready;

      if (kDebugMode) log("✅ WebSocket connected successfully");

      // Subscribe to the forum channel
      _safeSend({
        "type": "subscribe",
        "channelId": "forum_$forumId",
      });

      // Listen for messages
      _channelSubscription = channel?.stream.listen(
            (event) {
          if (kDebugMode) log("📥 WebSocket event: $event");

          final decodedEvent = jsonDecode(event);
          final type = decodedEvent['type'];

          switch (type) {
            case "newMessage":
              _messageCount++;
              if (kDebugMode) log("📨 New group message ($type), count: $_messageCount");
              _addToQueue(decodedEvent);
              break;
            case "reactionDelete":
              if (kDebugMode) log("🔁 Reaction deleted ($type)");
              _addToQueue(decodedEvent);
              break;
            case "reactionUpdate":
              if (kDebugMode) log("🔁 Reaction update ($type)");
              _addToQueue(decodedEvent);
              break;
            case "new_user_joined":
              if (kDebugMode) log("👤 New user joined");
              _addToQueue(decodedEvent);
              break;
          }
        },
        onError: (error) {
          if (kDebugMode) log("❌ WebSocket error: $error");
          _handleWebSocketDisconnect();
        },
        onDone: () {
          if (kDebugMode) log("🛑 WebSocket closed (onDone)");
          _handleWebSocketDisconnect();
        },
        cancelOnError: true,
      );

      // Heartbeat (Ping) every 30 seconds
      pingTimer?.cancel();
      pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _safeSend({"type": "ping"});
      });

    } catch (e, stack) {
      if (kDebugMode) log("❗ WebSocket connection failed: $e");
    }
  }

  void _safeSend(Map<String, dynamic> message) {
    try {
      if (channel != null) {
        channel!.sink.add(jsonEncode(message));
      }
    } catch (e) {
      if (kDebugMode) log("❗ Failed to send on WebSocket: $e");
    }
  }
  void _handleWebSocketDisconnect() {
    if (!mounted) return;
    pingTimer?.cancel();
    pingTimer = null;

    try {
      channel?.sink.close();
    } catch (_) {}

    // Optional: try reconnect after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (kDebugMode) log("🔄 Attempting reconnect...");
      _connectWebsocket(widget.group.cityId ?? 1, widget.group.id);
    });
  }


  Future<void> _fetchMessages({required bool isInitialLoad}) async {
    if (!mounted) return;
    final newMessages =
        await context.read<GroupDetailsCubit>().receivePublicMessages(
              widget.group.id ?? 1,
              isInitialLoad,
            );

    if (!isInitialLoad) {
      // Check if any of the new messages are from other users
      bool hasMessagesFromOthers =
          newMessages.any((message) => message.senderId != widget.userId);

      if (hasMessagesFromOthers && !_isScrolledToBottom()) {
        setState(() {
          _unreadMessageCount += 1;
          _showNewMessageBanner = true;
        });
        _startBannerTimer();
      } else if (_isScrolledToBottom()) {
        // Reset the banner if scrolled to bottom
        setState(() {
          _unreadMessageCount = 0;
          _showNewMessageBanner = false;
        });
      }
    }

    if (isInitialLoad) {
      _scrollToBottom();
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNewMessageBanner = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
      listener: (context, state) {
        state.maybeWhen(
            loaded: (
              list,
              group,
              isAdmin,
              userId,
              memberRequestCount,
            ) {
              ///Need to clarify
              // _fetchMessages(isInitialLoad: true);
            },
            orElse: () {});
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context)
                  .pop(false), // Return false to indicate no refresh needed
            ),
            title: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.forumName ?? 'Group',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert, // Three vertical dots icon
                ),
                onSelected: (String choice) {
                  if (choice ==
                      Translate.of(context).translate('leave_group')) {
                    showLeaveGroupConfirmation(context);
                  } else if (choice ==
                      Translate.of(context).translate('see_member')) {
                    Navigator.pushNamed(
                      context,
                      Routes.groupMembersDetails,
                      arguments: {
                        'groupId': widget.group.id,
                        'cityId': widget.group.cityId
                      },
                    );
                  } else if (choice.contains(
                      Translate.of(context).translate('member_requests'))) {
                    Navigator.pushNamed(context, Routes.memberRequestDetails,
                        arguments: {
                          'groupId': widget.group.id,
                          'cityId': widget.group.cityId
                        }).whenComplete((){
                          debugPrint("Member request popped");
                          context.read<GroupDetailsCubit>().updateMemberRequestCount();
                          context.read<GroupDetailsCubit>().fetchUserGroupKeys(widget.group.id!);
                    });
                  } else if (choice ==
                      Translate.of(context).translate('delete_group')) {
                    showDeleteGroupConfirmation(context);
                  } else if (choice ==
                      Translate.of(context).translate('edit_group')) {
                    Navigator.pushNamed(context, Routes.addGroups, arguments: {
                      'isNewGroup': false,
                      'forumDetails': widget.group
                    }).then((value) async {
                      if (value == true) {
                        await context
                            .read<GroupDetailsCubit>()
                            .onLoad();
                        _fetchMessages(isInitialLoad: true);
                      }
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  final memberRequestsText = widget.memberRequestCount !=
                              null &&
                          widget.memberRequestCount! > 0
                      ? "${Translate.of(context).translate('member_requests')} (${widget.memberRequestCount})"
                      : Translate.of(context).translate('member_requests');

                  return widget.isAdmin
                      ? widget.group.isPrivate == 1
                          ? {
                              Translate.of(context).translate('leave_group'),
                              Translate.of(context).translate('see_member'),
                              Translate.of(context).translate('edit_group'),
                              memberRequestsText,
                              Translate.of(context).translate('delete_group'),
                            }.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice.contains('member_requests')
                                    ? Translate.of(context)
                                        .translate('member_requests')
                                    : choice,
                                child: Text(choice),
                              );
                            }).toList()
                          : {
                              Translate.of(context).translate('leave_group'),
                              Translate.of(context).translate('see_member'),
                              Translate.of(context).translate('edit_group'),
                              Translate.of(context).translate('delete_group'),
                            }.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList()
                      : {
                          Translate.of(context).translate('leave_group'),
                          Translate.of(context).translate('see_member'),
                        }.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (_showNewMessageBanner)
                  GestureDetector(
                    onTap: () {
                      _scrollToUnreadMessage();
                      setState(() {
                        _showNewMessageBanner = false;
                        _unreadMessageCount = 0;
                      });
                    },
                    child: Container(
                      color: const Color(0xFFe30613),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              "${Translate.of(context).translate('new_message')} ($_unreadMessageCount)",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ChatMessageList(
                    scrollController: _scrollController,
                    inputFocusNode: _inputFocusNode,
                  ),
                ),
                ChatInput(
                  replyMessage: widget.replyTo,
                  onSend: (text, file) async {
                    _scrollToBottom();
                    await context.read<GroupDetailsCubit>().sendMessage(
                          widget.group.id ?? 1,
                          text,
                          widget.replyTo,
                          file,
                        );
                  },
                  onClear: () {
                    context.read<GroupDetailsCubit>().clearReplyMessage();
                  },
                  focusNode: _inputFocusNode,
                  isSending: widget.isSendingMessages,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToUnreadMessage() {
    if (_scrollController.hasClients && _unreadMessageCount > 0) {
      final unreadMessageOffset =
          _calculateOffsetForUnreadMessage(_unreadMessageCount);
      _scrollController.animateTo(
        unreadMessageOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  double _calculateOffsetForUnreadMessage(int messageCount) {
    const double messageHeight = 70.0;
    return messageHeight * messageCount;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }

  // Queue management methods to prevent race conditions
  void _addToQueue(Map<String, dynamic> event) {
    _messageQueue.add(event);
    if (kDebugMode) {
      log("🎯 Added event to queue. Queue size: ${_messageQueue.length}");
    }
    _startQueueProcessor();
  }

  void _startQueueProcessor() {
    if (_isProcessingQueue) return;

    _queueProcessor?.cancel();
    _queueProcessor =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _processQueue();
    });
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty || !mounted) return;

    _isProcessingQueue = true;

    try {
      final event = _messageQueue.removeAt(0);
      if (kDebugMode) {
        log("🔄 Processing queued event: ${event['type']}, Remaining: ${_messageQueue.length}");
      }

      if (event['type'] == "newMessage") {
        // Only fetch messages if it's not from the current user (to avoid conflicts with optimistic UI)
        final messageData =
            event['data'] is String ? jsonDecode(event['data']) : event['data'];
        final senderId =
            int.tryParse(messageData?['senderId']?.toString() ?? '');
        if (senderId != null && senderId != widget.userId) {
          await _fetchMessages(isInitialLoad: false);
        }
      } else if (event['type'] == "reactionDelete") {
        if (mounted) {
          context.read<GroupDetailsCubit>().removeReactionLocally(event);
        }
      } else if (event['type'] == "reactionUpdate") {
        if (mounted) {
          context.read<GroupDetailsCubit>().addReactionLocally(event);
        }
      } else if(event['type']=="new_user_joined"){
        if(mounted){
          if(widget.group.id!=null) {
            context.read<GroupDetailsCubit>().fetchUserGroupKeys(
                widget.group.id!);
          }
        }
      }

      // Stop processing if queue is empty
      if (_messageQueue.isEmpty) {
        _queueProcessor?.cancel();
        if (kDebugMode) {
          log("✅ Queue processing completed");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Error processing queue: $e");
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> showLeaveGroupConfirmation(BuildContext buildContext) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(Translate.of(context).translate('group_leave_confirmation')),
          content: Text(Translate.of(context)
              .translate('Are_you_sure_you_want_to_leave_this_group')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await buildContext
                    .read<GroupDetailsCubit>()
                    .removeGroupMember(widget.group.id, widget.group.cityId)
                    .then((isRemoved) {
                  if (isRemoved == RemoveUser.removed) {
                    if (!mounted) return;
                    Navigator.of(context).pop(true);
                  } else if (isRemoved == RemoveUser.onlyUser) {
                    if (!mounted) return;
                    Navigator.of(context).pop(false);
                    final popUpTitle =
                        Translate.of(context).translate('only_user');
                    final content =
                        Translate.of(context).translate('only_user_in_group');
                    showAdminPopup(context, popUpTitle, content);
                  } else if (isRemoved == RemoveUser.onlyAdmin) {
                    if (!mounted) return;
                    final popUpTitle =
                        Translate.of(context).translate('only_admin');
                    final content =
                        Translate.of(context).translate('add_another_admin');
                    Navigator.of(context).pop(false);
                    showAdminPopup(context, popUpTitle, content);
                  }
                });
              },
              child: Text(Translate.of(context).translate('yes')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(Translate.of(context).translate('no')),
            ),
          ],
        );
      },
    );
    if (result == true) {
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate refresh needed
    }
  }

  Future<void> showDeleteGroupConfirmation(BuildContext buildContext) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              Translate.of(context).translate('group_delete_confirmation')),
          content: Text(Translate.of(context)
              .translate('delete_group_info')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await buildContext
                    .read<GroupDetailsCubit>()
                    .requestDeleteGroup(widget.group.id, widget.group.cityId);
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pop(
                    context, true); // Return true to indicate refresh needed
              },
              child: Text(Translate.of(context).translate('yes')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(Translate.of(context).translate('no')),
            ),
          ],
        );
      },
    );
    if (result == true) {}
  }

  void showAdminPopup(BuildContext context, title, content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}