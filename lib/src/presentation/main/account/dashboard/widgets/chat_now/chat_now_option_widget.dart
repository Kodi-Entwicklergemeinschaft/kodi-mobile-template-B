
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/utils/translate.dart';

import '../../../../../../data/model/model_forum_group.dart';
import '../../../../../../utils/configs/routes.dart';

class ChatNowOptionWidget extends StatelessWidget {
  final ProductModel item;
  const ChatNowOptionWidget({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context); // Close the dialog
        Future.microtask(() {
          Navigator.pushNamed(context, Routes.chat, arguments: {
            'listingId': item.id,
            'isAdmin': true,
          });
        });
      },
      child: ListTile(
        leading: const Icon(Icons.chat),
        title:
        Text(Translate.of(context).translate('chat_now')),
      ),
    );
  }
}