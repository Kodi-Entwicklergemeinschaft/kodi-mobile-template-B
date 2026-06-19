// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/presentation/main/account/dashboard/chat/cubit/chat_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../../services/remot_config_service.dart';
import '../../../../widget/chat_widget/chat_input.dart';
import 'chat_message_list.dart';
import 'cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdmin;
  final int listingId;

  const ChatScreen({super.key, required this.isAdmin, required this.listingId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask or addPostFrameCallback to avoid build-time errors
    Future.microtask(() {
      context.read<ChatCubit>().onLoad(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) => state.maybeWhen(
        loading: () => const ChatLoading(),
        loaded: (messages, group, isAdmin, userId, userName, isLoadingMore,
                replyMessage, isSendingMessages) =>
            ChatLoaded(
          group: group,
          isAdmin: isAdmin,
          userId: userId,
          messages: messages,
          listingId: widget.listingId,
          replyTo: replyMessage,
          isSendingMessages: isSendingMessages,
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
  final int listingId;
  final ChatMessageModel? replyTo;
  final bool isSendingMessages;

  const ChatLoaded({
    super.key,
    required this.isAdmin,
    required this.userId,
    required this.group,
    this.messages,
    required this.listingId,
    required this.replyTo,
    required this.isSendingMessages,
  });

  @override
  State<ChatLoaded> createState() => _ChatLoadedState();
}

class _ChatLoadedState extends State<ChatLoaded> {
  WebSocketChannel? channel;
  StreamSubscription? _channelSubscription;
  Timer? pingTimer;
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  final FocusNode _inputFocusNode = FocusNode();
  bool isLoading = false;
  int _messageCount = 0; // Counter for incoming WebSocket messages

  // Message queue to prevent race conditions
  final List<Map<String, dynamic>> _messageQueue = [];
  bool _isProcessingQueue = false;
  Timer? _queueProcessor;
  @override
  void initState() {
    super.initState();
    _fetchMessages(isInitialLoad: true);
    _connectWebsocket(widget.group.cityId ?? 1, widget.listingId);
    // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _channelSubscription?.cancel();
    channel?.sink.close();
    if (pingTimer != null) {
      pingTimer?.cancel();
    }
    if (_queueProcessor != null) {
      _queueProcessor?.cancel();
    }
    _scrollController.removeListener(_onScroll); // Remove the scroll listener
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Scroll listener - can be used for other scroll-related functionality
  }

  bool _isScrolledToBottom() {
    // if (!_scrollController.hasClients) return false;
    const threshold = 5.0; // Small threshold for floating point precision
    return _scrollController.offset >=
        (_scrollController.position.maxScrollExtent - threshold);
  }

  Future<void> _connectWebsocket(int? cityId, int? listingId) async {
    final config = RemoteConfigService();

    final wsUrl = Uri.parse(config.wsUrl);
    channel = WebSocketChannel.connect(wsUrl);

    try {
      await channel?.ready;
      if (kDebugMode) {
        log("WebSocket connected successfully");
      }

      channel?.sink.add(jsonEncode({
        "type": "subscribe",
        "channelId": "listing_$listingId",
      }));
      _channelSubscription = channel?.stream.listen((event) {
        if (kDebugMode) {
          log("websocket event: $event");
        }
        final decodedEvent = jsonDecode(event);

        // Add events to queue instead of processing immediately
        if (decodedEvent['type'] == "newMessage") {
          _messageCount++; // Increment message counter
          if (kDebugMode) {
            log("📨 New message received! Total messages: $_messageCount, Queue size: ${_messageQueue.length}");
          }
          _addToQueue(decodedEvent);
        } else if (decodedEvent['type'] == "reactionDeleted" ||
            decodedEvent['type'] == "reactionUpdate") {
          if (kDebugMode) {
            log("� Dashboard chat reaction event received: ${decodedEvent['type']}");
          }
          _addToQueue(decodedEvent);
        }
      },
      onError: (error) {
        if (kDebugMode) log("❌ WebSocket error: $error");
        _handleWebSocketDisconnect();
      },
      onDone: (){
        if (kDebugMode) {
          print("websocket closed");
        }
      });

      Timer.periodic(const Duration(seconds: 30), (timer) {
        pingTimer = timer;
        channel?.sink.add(jsonEncode({"type": "ping"}));
      });
    } catch (e) {
      if (kDebugMode) {
        log("WebSocket connection failed: $e");
      }
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
    if (!isInitialLoad) {
      // For new messages, refresh without showing loading state
      await context
          .read<ChatCubit>()
          .onLoad(widget.listingId, showLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
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
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ChatMessageList(
                    scrollController: _scrollController,
                    inputFocusNode: _inputFocusNode,
                  ),
                ),
                ChatInput(
                  replyMessage: widget.replyTo,
                  onSend: (text, file) async {
                    // _scrollToBottom();
                    await context.read<ChatCubit>().onMessageSent(
                          widget.listingId,
                          text,
                          widget.replyTo,
                          file,
                        );
                  },
                  onClear: () {
                    context.read<ChatCubit>().clearReplyMessage();
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  // Queue management methods to prevent race conditions
  void _addToQueue(Map<String, dynamic> event) {
    _messageQueue.add(event);
    if (kDebugMode) {
      log("🎯 Added event to dashboard queue. Queue size: ${_messageQueue.length}");
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
        log("🔄 Processing dashboard queued event: ${event['type']}, Remaining: ${_messageQueue.length}");
      }

      if (event['type'] == "newMessage") {
        final messageData =
            event['data'] is String ? jsonDecode(event['data']) : event['data'];
        final senderId =
            int.tryParse(messageData?['senderId']?.toString() ?? '');
        if (senderId != null && senderId != widget.userId) {
          await _fetchMessages(isInitialLoad: false);
        }
      } else if (event['type'] == "reactionDeleted") {
        if (mounted) {
          context.read<ChatCubit>().removeReactionLocally(event);
        }
      } else if (event['type'] == "reactionUpdate") {
        if (mounted) {
          context.read<ChatCubit>().addReactionLocally(event);
        }
      }

      // Stop processing if queue is empty
      if (_messageQueue.isEmpty) {
        _queueProcessor?.cancel();
        if (kDebugMode) {
          log("✅ Dashboard queue processing completed");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log("❌ Error processing dashboard queue: $e");
      }
    } finally {
      _isProcessingQueue = false;
    }
  }
}
