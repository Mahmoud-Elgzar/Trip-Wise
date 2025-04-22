// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:demo1/ChatBot/providers/chat_provider.dart';
import 'package:demo1/ChatBot/utility/utilites.dart';
import 'package:demo1/ChatBot/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // Controller for the input field
  final TextEditingController textController = TextEditingController();

  // Focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  // Initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sendMessage(
        // Fixed: Changed sentMessage to sendMessage
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('Error sending message: $e');
      // Optionally show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  // Pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if (hasImages) const PreviewImagesWidget(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (hasImages) {
                    // Show the delete dialog
                    showMyAnimatedDialog(
                      context: context,
                      title: 'Delete Images',
                      content: 'Are you sure you want to delete the images?',
                      actionText: 'Delete',
                      onActionPressed: (value) {
                        if (value) {
                          widget.chatProvider.setImagesFileList(listValue: []);
                        }
                      },
                    );
                  } else {
                    pickImage();
                  }
                },
                icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.chatProvider.isLoading
                      ? null
                      : (String value) {
                          if (value.isNotEmpty) {
                            sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true,
                            );
                          }
                        },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter a prompt...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        if (textController.text.isNotEmpty) {
                          sendChatMessage(
                            message: textController.text,
                            chatProvider: widget.chatProvider,
                            isTextOnly: hasImages ? false : true,
                          );
                        }
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(5.0),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
