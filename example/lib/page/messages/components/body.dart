import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../constants.dart';
import '../../../reaction_widget.dart';
import 'chat_input_field.dart';
import 'message.dart';

class Body extends StatelessWidget {
  final TextEditingController controllerChat;
  final RefreshController refreshController;
  final VoidCallback onRefresh;
  final VoidCallback onLoading;
  final List<LiveTalkMessageEntity> messages;
  final Widget replyWidget;
  final Widget typingWidget;
  final VoidCallback onSendMessage;
  final VoidCallback onOpenFileOrImage;
  final Function(String? id, LiveTalkMessageEntity data)? replyCallback;
  final VoidCallback callBackSendSticky;
  const Body({
    Key? key,
    required this.onSendMessage,
    required this.onOpenFileOrImage,
    required this.replyWidget,
    required this.typingWidget,
    required this.messages,
    this.replyCallback,
    required this.refreshController,
    required this.onRefresh,
    required this.onLoading,
    required this.controllerChat,
    required this.callBackSendSticky,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: SmartRefresher(
              reverse: true,
              enablePullDown: true,
              enablePullUp: true,
              controller: refreshController,
              onRefresh: onRefresh,
              onLoading: onLoading,
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => Message(
                  data: messages[index],
                  longPress: (id) {
                    if (id == null) {
                      return;
                    }
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            child: const Text('Delete'),
                            onPressed: () async {
                              Navigator.pop(context);
                              EasyLoading.show();
                              await LiveTalkSdk.shareInstance
                                  .removeMessage(id: id);
                              EasyLoading.dismiss();
                              //delete
                            },
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: const Text('Cancel'),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  reactCallback: (id) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ), //this right here
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              ReactionWidget(
                                callback: (content) async {
                                  EasyLoading.show();
                                  await LiveTalkSdk.shareInstance
                                      .actionOnMessage(
                                    content: content,
                                    id: id ?? "",
                                    action: "REACT",
                                  );
                                  EasyLoading.dismiss();
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  replyCallback: replyCallback,
                ),
              ),
            ),
          ),
        ),
        replyWidget,
        typingWidget,
        ChatInputField(
          callBackSend: onSendMessage,
          onOpenFileOrImage: onOpenFileOrImage,
          controllerChat: controllerChat,
          callBackSendSticky: callBackSendSticky,
        ),
      ],
    );
  }
}
