import 'package:flutter/material.dart';

import '../../../constants.dart';

class ChatInputField extends StatelessWidget {
  final VoidCallback callBackSend;
  final VoidCallback callBackSendSticky;
  final VoidCallback onOpenFileOrImage;
  final TextEditingController controllerChat;
  const ChatInputField({
    Key? key,
    required this.callBackSend,
    required this.onOpenFileOrImage,
    required this.controllerChat,
    required this.callBackSendSticky,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.mic, color: kPrimaryColor),
            const SizedBox(width: kDefaultPadding / 2),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.64),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Expanded(
                      child: TextField(
                        controller: controllerChat,
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onOpenFileOrImage,
                      child: Icon(
                        Icons.attach_file,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    GestureDetector(
                      onTap: callBackSendSticky,
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.64),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: callBackSend,
              child: const Icon(Icons.send, size: 24, color: kPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
