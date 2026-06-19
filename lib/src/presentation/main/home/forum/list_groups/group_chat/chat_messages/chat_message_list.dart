import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_chat_message.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/group_details/cubit/group_details_cubit.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/group_details/cubit/group_details_state.dart';
import 'package:your_app_name/src/presentation/widget/chat_widget/chat_utils.dart';
import 'package:your_app_name/src/presentation/widget/emoji_reaction_dialog_widget.dart';
import 'package:your_app_name/src/utils/common.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:intl/intl.dart';

class ChatMessageList extends StatefulWidget {
  final ScrollController scrollController;
  final FocusNode inputFocusNode;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.inputFocusNode,
  });

  @override
  _ChatMessageListState createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  /// Local method to get chat bubble colors based on theme
  Color _getChatBubbleColor(BuildContext context, bool isMe) {
    if (isMe) {
      return const Color(0xFFe5634d);
    }

    // Local theming for non-user messages
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF2d2d30) // Dark gray for dark theme
        : const Color(0xFFf5f5f5); // Light gray for light theme
  }

  /// Local method to get text color based on theme and sender
  Color _getTextColor(BuildContext context, bool isMe) {
    if (isMe) {
      return Colors.white;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black87;
  }

  /// Local method to get reply attachment colors based on theme and sender
  Map<String, Color> _getReplyAttachmentColors(
      BuildContext context, bool isMe) {
    if (isMe) {
      return {
        'backgroundColor': Colors.black.withOpacity(0.15),
        'usernameColor': Colors.white,
        'borderColor': Colors.white.withOpacity(0.4),
        'textColor': Colors.white.withOpacity(0.85),
      };
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return {
        'backgroundColor': Colors.white.withOpacity(0.08),
        'usernameColor': Colors.white.withOpacity(0.95),
        'borderColor': Colors.white.withOpacity(0.25),
        'textColor': Colors.white.withOpacity(0.75),
      };
    } else {
      return {
        'backgroundColor': Colors.black.withOpacity(0.08),
        'usernameColor': Colors.black.withOpacity(0.95),
        'borderColor': Colors.black.withOpacity(0.25),
        'textColor': Colors.black.withOpacity(0.75),
      };
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _buildMessageContent(String messageText, bool isMe) {
    final urlPattern = RegExp(
      r'((https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}([\/\w\-.?#@!$&=]*)*)',
      caseSensitive: false,
    );

    final List<InlineSpan> textSpans = [];
    int lastIndex = 0;
    final matches = urlPattern.allMatches(messageText);

    for (final match in matches) {
      if (match.start > lastIndex) {
        textSpans.add(TextSpan(
          text: messageText.substring(lastIndex, match.start),
          style: TextStyle(color: _getTextColor(context, isMe)),
        ));
      }

      final url = match.group(0);
      textSpans.add(TextSpan(
        text: url,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (url != null && url.isNotEmpty) {
              Utils().launchURL(url);
            }
          },
      ));

      lastIndex = match.end;
    }

    if (lastIndex < messageText.length) {
      textSpans.add(TextSpan(
        text: messageText.substring(lastIndex),
        style: TextStyle(color: _getTextColor(context, isMe)),
      ));
    }

    return RichText(
      text: TextSpan(children: textSpans),
      softWrap: true,
    );
  }

  Future<void> _scrollListener() async {
    if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      final chatCubit = context.read<GroupDetailsCubit>();
      final currentState = chatCubit.state;

      if (currentState is GroupDetailsStateMessagesLoaded &&
          !(currentState.isLoadingMore)) {
        await context
            .read<GroupDetailsCubit>()
            .fetchOlderMessages(context.read<GroupDetailsCubit>().forumId);
      }
    }
  }

  String formatDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    return DateFormat('EEE, d. MMM yyyy, HH:mm \'Uhr\'', 'de_DE')
        .format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        return state.maybeWhen(
          messagesLoaded: (messages, group, isAdmin, userId, replyTo,
              isLoadingMore, isSendingMessage, memberRequestCount) {
            return _getLoadedMessageList(messages, userId);
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _getLoadedMessageList(List<ChatMessageModel> messages, int userId) {
    final isLoadingMore = context.read<GroupDetailsCubit>().state.maybeWhen(
          messagesLoaded: (messages, group, isAdmin, userId, replyTo,
              isLoadingMore, isSendingMessage, memberRequestCount) {
            return isLoadingMore;
          },
          orElse: () => false,
        );

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: isLoadingMore ? messages.length + 1 : messages.length,
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (isLoadingMore && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final message = messages[index];
        final isMe = message.senderId == userId;
        return ((message.message != null && message.message!.isNotEmpty) ||
                (message.fileUrl != null && message.fileUrl!.isNotEmpty))
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isMe)
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          message.avatarUrl == ""
                              ? '${Application.picturesURL}admin/ProfilePicture.png'
                              : '${Application.picturesURL}${message.avatarUrl}',
                        ),
                      ),
                    if (!isMe) const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              message.username ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onLongPressStart:
                              (LongPressStartDetails details) async {
                            final position = details.globalPosition;
                            Reactions? currentUserReaction;
                            try {
                              currentUserReaction = message.reactions
                                  ?.firstWhere((r) => r.userId == userId);
                            } catch (e) {
                              // Handle the case where no reaction is found, if necessary
                            }

                            await showGeneralDialog<MapEntry<int, String>>(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Dismiss",
                              barrierColor: Colors.black54,
                              transitionDuration:
                                  const Duration(milliseconds: 150),
                              pageBuilder: (_, __, ___) => EmojiReactionDialog(
                                isMe: isMe,
                                message: message.message,
                                currentUserReactionId:
                                    currentUserReaction?.reaction,
                                position: position,
                                onSelected: (value) {
                                  context
                                      .read<GroupDetailsCubit>()
                                      .onReactionSent(message.id!, value.key);
                                  debugPrint('Selected Emoji: ${value.key}');
                                  // Remove existing reaction from this user and add new one
                                  message.reactions
                                      ?.removeWhere((r) => r.userId == userId);
                                  // setState(() {
                                  //   message.reactions = [...?message.reactions, newReaction];
                                  // });
                                },
                                onTapRemove: () {
                                  context
                                      .read<GroupDetailsCubit>()
                                      .onReactionRemoved(message.id!);
                                  // setState(() {
                                  //   message.reactions?.removeWhere((r) => r.userId == userId);
                                  // });
                                },
                                onTapReply: (){
                                  context.read<GroupDetailsCubit>().setReplyMessage(message);
                                },
                              ),
                            );
                          },
                          child: Dismissible(
                            key: ValueKey(message.id),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (_) {
                              // Trigger reply UI with the selected message
                            },
                            confirmDismiss: (_) async {
                              // Prevent actual dismissal (we only want the gesture)
                              context
                                  .read<GroupDetailsCubit>()
                                  .setReplyMessage(message);
                              return false;
                            },
                            background: Container(
                              alignment: isMe
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.reply),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 14),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getChatBubbleColor(context, isMe),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        message.status == MessageStatus.failed
                                            ? Border.all(
                                                color: Colors.red, width: 1)
                                            : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (message.parentId != null) ...[
                                        Builder(
                                          builder: (context) {
                                            final replyColors =
                                                _getReplyAttachmentColors(
                                                    context, isMe);
                                            return ChatUtils()
                                                .buildReplyAttachment(
                                              context,
                                              message,
                                              isMe: isMe,
                                              backgroundColor: replyColors[
                                                  'backgroundColor']!,
                                              textColor:
                                                  replyColors['textColor']!,
                                              usernameColor:
                                                  replyColors['usernameColor']!,
                                              borderColor:
                                                  replyColors['borderColor']!,
                                            );
                                          },
                                        ),
                                      ],
                                      if (message.fileUrl != null)
                                        ChatUtils().buildFileAttachment(
                                            context, message.fileUrl!,
                                          status: message.status,
                                        ),
                                      if (message.message != null &&
                                          message.message!.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: message.parentId != null
                                                  ? 0
                                                  : 10,
                                              bottom: 10,
                                              left: 14,
                                              right: 14),
                                          child: _buildMessageContent(
                                              message.message ?? '', isMe),
                                        ),
                                      // Add status indicators for sent messages
                                      if (isMe && message.status != null)
                                        _buildMessageStatus(message, context),
                                    ],
                                  ),
                                ),
                                if (message.reactions != null &&
                                    message.reactions!.isNotEmpty)
                                  ChatUtils()
                                      .showReactions(context, isMe, message),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              message.createdAt != null
                                  ? formatDate(message.createdAt!)
                                  : formatDate(
                                      DateTime.now().toIso8601String()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                            if (isMe &&
                                message.status == MessageStatus.failed) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.error_outline,
                                size: 12,
                                color: Colors.red,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (isMe) const SizedBox(width: 10),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget _buildMessageStatus(ChatMessageModel message, BuildContext context) {
    switch (message.status) {
      case MessageStatus.sending:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sending...',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      case MessageStatus.failed:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (message.tempId != null) {
                    context
                        .read<GroupDetailsCubit>()
                        .retryFailedMessage(message.tempId!);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case MessageStatus.sent:
      default:
        return const SizedBox.shrink();
    }
  }
}