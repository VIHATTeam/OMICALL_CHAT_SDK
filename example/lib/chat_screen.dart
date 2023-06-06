import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  int size = 15;
  List<LiveTalkMessageEntity> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    getMessageHistory();
    super.initState();
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

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              reverse: true,
              enablePullDown: true,
              enablePullUp: true,
              header: const WaterDropHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
                  await LiveTalkSdk.shareInstance
                      .sendMessage(message: _controller.text);
                  _controller.clear();
                  EasyLoading.dismiss();
                },
                child: Container(
                  height: 50,
                  width: 50,
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
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
