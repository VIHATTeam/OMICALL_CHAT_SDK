import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livetalk_sdk/entity/entity.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'create_user_form_screen.dart';
import 'dialog/dialog.dart';
import 'items/message_item.dart';
import 'items/rep_message_widget.dart';
import 'reaction_widget.dart';
import 'package:livetalk_sdk_example/socket_test_screen.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String uuid;
  final String? title;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.uuid,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<ChatScreen> {
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
  String? titleText;

  @override
  void initState() {
    super.initState();
    titleText = widget.title;
    initData();
    _uploadFileSubscription =
        LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
      debugPrint("Upload event received: $event");
      debugPrint("task_id ${event["task_id"]}");
      int status = event["status"];
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
        titleText = member.fullName;
        isAdminOnline = member.status == "online";
      } else {
        titleText = "Wait accept";
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

  Future<void> _logout() async {
    EasyLoading.show();
    await LiveTalkSdk.shareInstance.logout(widget.uuid);
    EasyLoading.dismiss();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CreateUserFormScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText ?? "LiveTalk SDK Demo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SocketTestScreen(
                    roomId: widget.roomId,
                    uuid: widget.uuid,
                  ),
                ),
              );
            },
            tooltip: "Kiểm tra socket",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              reverse: true,
              enablePullDown: true,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemBuilder: (context, index) {
                  return MessageItem(
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
                    replyCallback: (id) {
                      focusNode.requestFocus();
                      setState(() {
                        _repMessage = messages[index];
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 12,
                  );
                },
                itemCount: messages.length,
              ),
            ),
          ),
          if (_repMessage != null)
            Container(
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
          if (isTyping) ...[
            const SizedBox(
              height: 6,
            ),
            Align(
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
            )
          ],
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: _controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 12,
                    ),
                    prefixIcon: const Icon(Icons.cleaning_services),
                    labelText: "Input",
                    enabledBorder: myInputBorder(),
                    focusedBorder: myFocusBorder(),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    EasyLoading.show();
                    final sendingMessage =
                        LiveTalkSendingMessage.createTxtSendMessage(
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
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal,
                        Colors.teal[200]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(5, 5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.send,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () async {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext dialogContext) =>
                        CupertinoActionSheet(
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          child: const Text('Files'),
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            final ImagePicker picker = ImagePicker();
                            final List<XFile> images = await picker.pickMultiImage();
                            if (images.isNotEmpty) {
                              EasyLoading.show();
                              try {
                                final sendingMessage =
                                    LiveTalkSendingMessage.createTxtSendFiles(
                                  paths: images.map((e) => e.path).toList(),
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
                            final ImagePicker picker = ImagePicker();
                            final List<XFile> images = await picker.pickMultiImage();
                            if (images.isNotEmpty) {
                              EasyLoading.show();
                              try {
                                final sendingMessage =
                                    LiveTalkSendingMessage.createTxtSendFiles(
                                  paths: images.map((e) => e.path).toList(),
                                );
                                final taskResponse = await LiveTalkSdk
                                    .shareInstance
                                    .sendMessage(sendingMessage);
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
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal,
                        Colors.teal[200]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(5, 5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.file_upload,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    EasyLoading.show();
                    final sendingMessage =
                        LiveTalkSendingMessage.createSendSticker(
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
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal,
                        Colors.teal[200]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(5, 5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sticky_note_2,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
