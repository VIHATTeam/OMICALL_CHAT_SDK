import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:images_picker/images_picker.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk_example/page/auth/login_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../constants.dart';
import '../../dialog/dialog.dart';
import '../../items/rep_message_widget.dart';
import '../../main.dart';
import 'components/body.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int page = 1;
  int size = 20;
  List<LiveTalkMessageEntity> messages = [];
  bool isLoading = false;
  late StreamSubscription<LiveTalkEventEntity> _messageSubscription;
  late StreamSubscription<Map<String, dynamic>> _uploadFileSubscription;

  bool isTyping = false;
  bool isAdminOnline = false;
  final FocusNode focusNode = FocusNode();
  LiveTalkMessageEntity? _repMessage;
  String? title;

  @override
  void initState() {
    initData();
    super.initState();
    _uploadFileSubscription =
        LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
      int status = event["status"];
      debugPrint("taskId ${event["taskId"]}");
      if (status >= 3) {
        EasyLoading.dismiss();
      }
    });
    _messageSubscription =
        LiveTalkSdk.shareInstance.eventStream.listen((result) {
      final event = result.eventName;
      final data = result.data;
      if (event == "message" && data != null) {
        setState(() {
          messages.insert(0, LiveTalkMessageEntity.fromJson(data));
        });
        return;
      }
      if (event == "someone_typing") {
        setState(() {
          isTyping = data!["isTyping"];
        });
      }
      if (event == "member_join") {
        initData();
      }
      if (event == "member_disconnect") {
        setState(() {
          isAdminOnline = false;
        });
      }
      if (event == "member_connect") {
        setState(() {
          isAdminOnline = true;
        });
      }
      if (event == "lt_reaction") {
        LiveTalkMessageEntity? message =
            messages.cast<LiveTalkMessageEntity?>().firstWhere(
                  (element) => element?.id == data!["msg_id"],
                  orElse: () => null,
                );
        if (message != null) {
          message.setNewReaction(data!["reactions"]);
        }
        setState(() {});
        return;
      }
      if (event == "remove_message") {
        final msgId = data!["message_id"];
        setState(() {
          messages.removeWhere((element) => element.id == msgId);
        });
        return;
      }
    });
  }

  Future<void> initData() async {
    try {
      EasyLoading.show();
      final currentRoom = await LiveTalkSdk.shareInstance.getCurrentRoom();
      if (currentRoom == null) {
        EasyLoading.dismiss();
        return;
      }
      if (currentRoom.hasMember == true &&
          currentRoom.members?.isNotEmpty == true) {
        final member = currentRoom.members!.first;
        title = member.fullName;
        isAdminOnline = member.status == "online";
      } else {
        title = "Wait accept";
      }
      await getMessageHistory();
      EasyLoading.dismiss();
    } catch (e) {
      if (e is LiveTalkError) {
        EasyLoading.dismiss();
        showCustomDialog(
          context: context,
          message: e.message["message"],
        );
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    _refreshController.dispose();
    _controller.dispose();
    _messageSubscription.cancel();
    _uploadFileSubscription.cancel();
    LiveTalkSdk.shareInstance.disconnect();
    super.dispose();
  }

  Future<void> getMessageHistory() async {
    isLoading = true;
    final data = await LiveTalkSdk.shareInstance.getMessageHistory(
      page: page,
      size: size,
    );
    isLoading = false;
    setState(() {
      if (page == 1) {
        messages = data;
      } else {
        messages.addAll(data);
      }
    });
  }

  Future<void> _onRefresh() async {
    page = 1;
    await getMessageHistory();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (isLoading) {
      return;
    }
    page += 1;
    await getMessageHistory();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(
        onSendMessage: () async {
          try {
            EasyLoading.show();
            final sendingMessage = LiveTalkSendingMessage.createTxtSendMessage(
              message: _controller.text,
              quoteId: _repMessage?.id,
            );
            await LiveTalkSdk.shareInstance.sendMessage(sendingMessage);
            if (_repMessage != null) {
              setState(() {
                _repMessage = null;
              });
            }
            _controller.clear();
            EasyLoading.dismiss();
          } catch (error) {
            EasyLoading.dismiss();
            if (error is LiveTalkError) {
              showCustomDialog(
                context: context,
                message: error.message["message"] as String,
              );
            }
          }
        },
        onOpenFileOrImage: () async {
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext dialogContext) => CupertinoActionSheet(
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  child: const Text('Files'),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true);
                    if (result != null) {
                      EasyLoading.show();
                      try {
                        final sendingMessage =
                            LiveTalkSendingMessage.createTxtSendFiles(
                          paths: result.paths.cast<String>(),
                        );
                        final taskResponse =
                            await LiveTalkSdk.shareInstance.sendMessage(
                          sendingMessage,
                        );
                        debugPrint(taskResponse?.toString());
                      } catch (error) {
                        if (error is LiveTalkError) {
                          EasyLoading.dismiss();
                          if (mounted) {
                            showCustomDialog(
                              context: context,
                              message: error.message["message"],
                            );
                          }
                        }
                      }
                    }
                  },
                ),
                CupertinoActionSheetAction(
                  child: const Text('Images/Videos'),
                  onPressed: () async {
                    Navigator.pop(context);
                    List<Media>? res = await ImagesPicker.pick(
                      count: 3,
                      pickType: PickType.all,
                    );
                    if (res?.isNotEmpty == true) {
                      EasyLoading.show();
                      try {
                        final sendingMessage =
                            LiveTalkSendingMessage.createTxtSendFiles(
                          paths: res!.map((e) => e.path).toList(),
                        );
                        final taskResponse = await LiveTalkSdk.shareInstance
                            .sendMessage(sendingMessage);
                        debugPrint(taskResponse?.toString());
                        // EasyLoading.dismiss();
                      } catch (error) {
                        if (error is LiveTalkError) {
                          EasyLoading.dismiss();
                          if (mounted) {
                            showCustomDialog(
                              context: context,
                              message: error.message["message"],
                            );
                          }
                        }
                      }
                    }
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
        replyWidget: _repMessage == null
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.25),
                ),
                child: Row(
                  children: [
                    RepMessageItem(
                      data: _repMessage!,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _repMessage = null;
                        });
                      },
                      child: const Icon(
                        Icons.cancel,
                        size: 24,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
        typingWidget: isTyping
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: const Text(
                      "Admin đang trả lời ...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        messages: messages,
        replyCallback: (id, data) {
          focusNode.requestFocus();
          setState(() {
            _repMessage = data;
          });
        },
        refreshController: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        controllerChat: _controller,
        callBackSendSticky: () async {
          try {
            EasyLoading.show();
            final sendingMessage = LiveTalkSendingMessage.createSendSticker(
              sticker: _controller.text,
            );
            await LiveTalkSdk.shareInstance.sendMessage(sendingMessage);
            if (_repMessage != null) {
              setState(() {
                _repMessage = null;
              });
            }
            _controller.clear();
            EasyLoading.dismiss();
          } catch (error) {
            EasyLoading.dismiss();
            if (error is LiveTalkError) {
              showCustomDialog(
                context: context,
                message: error.message["message"] as String,
              );
            }
          }
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          //BackButton(),
          const Icon(
            Icons.face,
            size: 45,
          ),

          const SizedBox(width: kDefaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                isAdminOnline ? "Active now" : "No active",
                style: const TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.logout,
            // size: 24,
            // color: Colors.white,
          ),
          onPressed: () async {
            EasyLoading.show();
            await LiveTalkSdk.shareInstance.logout(uuid);
            EasyLoading.dismiss();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          },
        ),
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }
}
