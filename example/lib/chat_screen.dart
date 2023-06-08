import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:images_picker/images_picker.dart';
import 'package:livetalk_sdk/entity/live_talk_message_entity.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'create_user_form_screen.dart';
import 'items/message_item.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
  late StreamSubscription _messageSubscription;

  @override
  void initState() {
    getMessageHistory();
    super.initState();
    _messageSubscription =
        LiveTalkSdk.shareInstance.eventStream.listen((result) {
      final event = result["event"];
      final data = result["data"];
      if (event == "message") {
        setState(() {
          messages.insert(0, data as LiveTalkMessageEntity);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    _messageSubscription.cancel();
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
      appBar: AppBar(
        title: const Text("Chat"),
        automaticallyImplyLeading: false,
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
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 8,
                  );
                },
                itemCount: messages.length,
              ),
            ),
          ),
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
                  controller: _controller,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
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
                  EasyLoading.show();
                  await LiveTalkSdk.shareInstance.sendMessage(
                    message: _controller.text,
                  );
                  _controller.clear();
                  EasyLoading.dismiss();
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
              const SizedBox(width: 12,),
              GestureDetector(
                onTap: () async {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          child: const Text('Files'),
                          onPressed: () async {
                            Navigator.pop(context);
                            FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
                            if (result != null) {
                              EasyLoading.show();
                              await LiveTalkSdk.shareInstance.sendFiles(paths: result.paths.cast<String>());
                              EasyLoading.dismiss();
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
                              maxSize: 512,
                            );
                            if (res?.isNotEmpty == true) {
                              EasyLoading.show();
                              await LiveTalkSdk.shareInstance.sendFiles(paths: res!.map((e) => e.path).toList());
                              EasyLoading.dismiss();
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
