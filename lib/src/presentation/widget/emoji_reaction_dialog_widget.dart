import 'package:flutter/material.dart';
import 'package:your_app_name/src/utils/common.dart';

import '../../utils/common_map.dart';

class EmojiReactionDialog extends StatelessWidget {
  final bool? isMe;
  final Offset? position;
  final Function(MapEntry<int, String>)? onSelected;
  final VoidCallback? onTapRemove;
  final VoidCallback? onTapReply;
  final int? currentUserReactionId;
  final String? message;


  const EmojiReactionDialog({
    super.key,
    this.isMe,
    this.position,
    this.onSelected,
    this.onTapRemove,
    this.onTapReply,
    this.currentUserReactionId,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: (position?.dy ?? 100)-100,
            left: (isMe ?? false) ? null : ((position?.dx ?? 100) < 200 ? (position?.dx ?? 100) : null),
            right: (isMe ?? false) ? (MediaQuery.of(context).size.width - (position?.dx ?? 100)) : ((position?.dx ?? 100) > MediaQuery.of(context).size.width - 200 ? (MediaQuery.of(context).size.width - (position?.dx ?? 100)) : null),
            child: Material(
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 8.0,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Wrap(
                  spacing: 10,
                  children: emoticons.entries.map((entry) {
                    final isSelected = entry.key == currentUserReactionId;
      
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (isSelected) {
                          onTapRemove?.call();
                        } else {
                          onSelected?.call(entry);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey.withOpacity(0.3) : null,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (message != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Theme.of(context).dialogBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                         Navigator.of(context).pop();
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Utils().copyToClipboard(context, message!);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.reply),
                          onPressed: () {
                            onTapReply?.call();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
