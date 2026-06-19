import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/utils/translate.dart';

import '../../../data/model/model_chat_message.dart';

class ChatInput extends StatefulWidget {
  final Function(String, File?) onSend;
  final bool isSending;
  final FocusNode focusNode;
  final ChatMessageModel? replyMessage;
  final Function()? onClear;

  const ChatInput({
    super.key,
    required this.isSending,
    required this.onSend,
    required this.focusNode,
    this.replyMessage,
    this.onClear,
  });

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyMessage != null) _buildReplyPreview(context),
          if (_selectedMedia != null) _buildMediaPreview(context),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: Translate.of(context).translate('type_message'),
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () async {
                        if (Platform.isIOS) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.image),
                                      title: Text(Translate.of(context)
                                          .translate('image')),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                        );
                                        if (result != null) {
                                          setState(() {
                                            _selectedMedia =
                                                File(result.files.single.path!);
                                          });
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.picture_as_pdf),
                                      title: Text(Translate.of(context)
                                          .translate('pdf')),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );
                                        if (result != null) {
                                          setState(() {
                                            _selectedMedia =
                                                File(result.files.single.path!);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                          );
                          if (result != null) {
                            setState(() {
                              _selectedMedia = File(result.files.single.path!);
                            });
                          }
                        }
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              widget.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () {
                        final message = _controller.text.trim();
                        if (message.isNotEmpty || _selectedMedia != null) {
                          widget.onSend(message, _selectedMedia);
                          setState(() => _selectedMedia = null);
                          _controller.clear();
                          widget.focusNode.requestFocus();
                        }
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.replyMessage?.username ??
                      widget.replyMessage?.firstname ??
                      '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.replyMessage?.message ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClear,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          _selectedMedia!.path.endsWith('.pdf')
              ? const Icon(Icons.picture_as_pdf, size: 40)
              : Image.file(
                  _selectedMedia!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedMedia!.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedMedia = null)),
        ],
      ),
    );
  }
}
