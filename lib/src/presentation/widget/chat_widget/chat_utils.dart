import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:your_app_name/src/utils/common.dart';

import '../../../data/model/model_chat_message.dart';
import '../../../utils/common_map.dart';
import '../../../utils/configs/application.dart';
import '../../../utils/translate.dart';

class ChatUtils {
  ///Singleton factory
  static final ChatUtils _instance = ChatUtils._internal();

  factory ChatUtils() {
    return _instance;
  }

  ChatUtils._internal();

  void _showReactedUsersBottomSheet(
      BuildContext context, List<Reactions> reactions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translate.of(context).translate('reactions'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reactions.length,
                  itemBuilder: (context, index) {
                    final reaction = reactions[index];
                    final emoji = emoticons[reaction.reaction] ?? '';
                    return ListTile(
                      leading: Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(reaction.username ??
                          Translate.of(context).translate('unknown_user')),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text(Translate.of(context).translate('close')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget showReactions(
      BuildContext context, bool isMe, ChatMessageModel message) {
    return Positioned(
      bottom: 0,
      right: isMe ? 0 : null,
      left: isMe ? null : 0,
      child: GestureDetector(
        onTap: () {
          _showReactedUsersBottomSheet(context, message.reactions!);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              // Display unique emojis
              ...message.reactions!
                  .map((reaction) => emoticons[reaction.reaction] ?? '')
                  .toSet() // Get unique emoji strings
                  .map((emojiString) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    emojiString,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
              // Display total reaction count
              if (message.reactions!.isNotEmpty &&
                  message.reactions!.length > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    message.reactions!.length.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFileAttachment(BuildContext context, String url,
      {MessageStatus? status}) {
    final fileUrl = "${Application.picturesURL}$url";

    if (status == MessageStatus.sending) {
      return const SizedBox();
    }

    if (Utils().isImageUrl(fileUrl)) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                ),
                body: Center(
                  child: CachedNetworkImage(
                    imageUrl: fileUrl,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        (status != null && status == MessageStatus.sending)
                            ? const SizedBox()
                            : const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: fileUrl,
            fit: BoxFit.fill,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
    } else if (Utils().isPdfUrl(fileUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            // borderRadius: BorderRadius.circular(20), // Moved to ClipRRect
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(),
                    body: const PDF().cachedFromUrl(
                      fileUrl,
                      placeholder: (progress) =>
                          Center(child: Text('$progress %')),
                      errorWidget: (error) =>
                          Center(child: Text(error.toString())),
                    ),
                  ),
                ),
              );
            },
            child: AbsorbPointer(
                child: Center(
              child: const PDF().cachedFromUrl(
                fileUrl,
                placeholder: (progress) => Center(child: Text('$progress %')),
                errorWidget: (error) => Center(child: Text(error.toString())),
              ),
            )),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildReplyAttachment(BuildContext context, ChatMessageModel message,
      {bool isMe = false,
      Color? backgroundColor,
      Color? textColor,
      Color? usernameColor,
      Color? borderColor}) {
    // Use provided colors or fall back to theme-based defaults
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color finalBackgroundColor;
    Color finalUsernameColor;
    Color finalBorderColor;
    Color finalMessageTextColor;

    if (backgroundColor != null &&
        textColor != null &&
        usernameColor != null &&
        borderColor != null) {
      // Use provided colors
      finalBackgroundColor = backgroundColor;
      finalUsernameColor = usernameColor;
      finalBorderColor = borderColor;
      finalMessageTextColor = textColor;
    } else {
      // Fall back to original logic for backward compatibility
      if (isMe) {
        // Sender message (red background) - use darker overlay
        finalBackgroundColor = Colors.black.withOpacity(0.15);
        finalUsernameColor = Colors.white;
        finalBorderColor = Colors.white.withOpacity(0.4);
        finalMessageTextColor = Colors.white.withOpacity(0.85);
      } else {
        // Receiver message - adapt to theme
        if (isDark) {
          finalBackgroundColor = Colors.white.withOpacity(0.08);
          finalUsernameColor = Colors.white.withOpacity(0.95);
          finalBorderColor = Colors.white.withOpacity(0.25);
          finalMessageTextColor = Colors.white.withOpacity(0.75);
        } else {
          finalBackgroundColor = Colors.black.withOpacity(0.08);
          finalUsernameColor = Colors.black.withOpacity(0.95);
          finalBorderColor = Colors.black.withOpacity(0.25);
          finalMessageTextColor = Colors.black.withOpacity(0.75);
        }
      }
    }

    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: finalBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: finalBorderColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.parentUsername ?? 'Unknown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: finalUsernameColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.parentMessage ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: finalMessageTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
