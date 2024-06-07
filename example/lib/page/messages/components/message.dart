import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk_example/extensions/string_extension.dart';

import '../../../audio_preview.dart';
import '../../../constants.dart';
import '../../../datetime_helper.dart';
import '../../../image_preview.dart';
import '../../../items/rep_message_widget.dart';
import '../../../models/ChatMessage.dart';
import '../../../video_preview.dart';
import 'audio_message.dart';
import 'file_message.dart';
import 'text_message.dart';
import 'video_message.dart';

class Message extends StatefulWidget {
  final LiveTalkMessageEntity data;
  final Function(String? id)? longPress;
  final Function(String? id)? reactCallback;
  final Function(String? id, LiveTalkMessageEntity data)? replyCallback;
  const Message({
    Key? key,
    required this.data,
    this.longPress,
    this.reactCallback,
    this.replyCallback,
  }) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool isNewValue = false;
  bool isShow = false;
  @override
  Widget build(BuildContext context) {
    bool isGuest = widget.data.memberType == "guest";

    return GestureDetector(
      onLongPress: isGuest
          ? () {
              if (widget.longPress != null) {
                widget.longPress!(widget.data.id);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.only(top: kDefaultPadding),
        child: buildMessageChat(isGuest),
      ),
    );
  }

  Widget buildMessageChat(
    bool isGuest,
  ) {
    if (widget.data.memberType == "system") {
      return systemMessage;
    }
    if (widget.data.multimedias?.isNotEmpty == true) {
      return Row(
        mainAxisAlignment:
            !isGuest ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isGuest) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  isNewValue = !isNewValue;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(!isNewValue ? 0 : 8),
                child: const Icon(
                  Icons.more_vert,
                  color: kPrimaryColor,
                ),
              ),
            ),
            AnimatedContainer(
              margin: EdgeInsets.only(right: !isNewValue ? 0 : 8),
              height: !isNewValue ? 0 : 90,
              width: !isNewValue ? 0 : 50,
              duration: const Duration(milliseconds: 200),
              onEnd: () {
                setState(() {
                  isShow = !isShow;
                });
              },
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: !isNewValue
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
              ),
              child: !isNewValue
                  ? const SizedBox.shrink()
                  : isShow
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            reactWidget(),
                            replyWidget(),
                          ],
                        )
                      : const SizedBox.shrink(),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FileMessage(
                message: widget.data,
              ),
              reactionWidget,
            ],
          ),
          if (!isGuest) ...[
            const SizedBox(
              width: 6,
            ),
            reactWidget(),
            const SizedBox(
              width: 6,
            ),
            replyWidget(),
          ],
        ],
      );
    }
    return Row(
      mainAxisAlignment:
          isGuest ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isGuest) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Icon(
              Icons.account_circle,
              size: 30,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: kDefaultPadding / 2),
        ],
        if (isGuest) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                isNewValue = !isNewValue;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(!isNewValue ? 0 : 8),
              child: const Icon(
                Icons.more_vert,
                color: kPrimaryColor,
              ),
            ),
          ),
          AnimatedContainer(
            margin: EdgeInsets.only(right: !isNewValue ? 0 : 8),
            height: 40,
            width: !isNewValue ? 0 : 100,
            duration: const Duration(milliseconds: 200),
            onEnd: () {
              setState(() {
                isShow = !isShow;
              });
            },
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: !isNewValue
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
            ),
            child: !isNewValue
                ? const SizedBox.shrink()
                : isShow
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          replyWidget(),
                          reactWidget(),
                        ],
                      )
                    : const SizedBox.shrink(),
          ),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.data.quoteMessage != null) ...[
              Row(
                children: [
                  RepMessageItem(data: widget.data.quoteMessage!),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    "Reply by",
                    style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextMessage(message: widget.data),
                reactionWidget,
              ],
            ),
          ],
        ),
        if (!isGuest) ...[
          AnimatedContainer(
            margin: EdgeInsets.only(left: !isNewValue ? 0 : 8),
            height: 40,
            width: !isNewValue ? 0 : 100,
            duration: const Duration(milliseconds: 200),
            onEnd: () {
              setState(() {
                isShow = !isShow;
              });
            },
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: !isNewValue
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
            ),
            child: !isNewValue
                ? const SizedBox.shrink()
                : isShow
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          reactWidget(),
                          replyWidget(),
                        ],
                      )
                    : const SizedBox.shrink(),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isNewValue = !isNewValue;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(!isNewValue ? 2 : 8),
              child: const Icon(
                Icons.more_vert,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget get systemMessage {
    final action = widget.data.action;
    if (action == "create_room") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${DateTimeHelper.timestampToString(widget.data.lastUpdatedDate ?? 0)} Bạn đã để lại thông tin",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "${widget.data.guestInfo?.fullName ?? ""} | ${widget.data.guestInfo?.phone ?? ""}",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
            ),
          )
        ],
      );
    }
    return Text(
      widget.data.content ?? "",
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    );
  }

  Widget reactWidget() {
    return GestureDetector(
      child: const Icon(
        Icons.add_reaction_outlined,
        color: kPrimaryColor,
        size: 24,
      ),
      onTap: () {
        if (widget.reactCallback != null) {
          widget.reactCallback!(widget.data.id);
        }
      },
    );
  }

  Widget replyWidget() {
    return GestureDetector(
      child: const Icon(
        Icons.reply,
        color: kPrimaryColor,
        size: 24,
      ),
      onTap: () {
        if (widget.replyCallback != null) {
          widget.replyCallback!(widget.data.id, widget.data);
        }
      },
    );
  }

  Widget get reactionWidget {
    if (widget.data.reactions?.isNotEmpty == true) {
      return SizedBox(
        height: 20,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Text(
              widget.data.reactions![index].reaction ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 1,
            );
          },
          itemCount: widget.data.reactions!.length > 5
              ? 5
              : widget.data.reactions!.length,
        ),
      );
    }
    return const SizedBox();
  }
}

class ReactWidget extends StatelessWidget {
  final Function() reactCallback;
  const ReactWidget({Key? key, required this.reactCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: reactCallback,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.add_reaction_outlined,
            color: kPrimaryColor,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Reaction',
            style: TextStyle(
              fontSize: 16,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ReplyWidget extends StatelessWidget {
  final VoidCallback replyCallback;
  const ReplyWidget({
    Key? key,
    required this.replyCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: replyCallback,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.reply,
            color: kPrimaryColor,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Reply',
            style: TextStyle(
              fontSize: 16,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({Key? key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.not_sent:
          return kErrorColor;
        case MessageStatus.not_view:
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return kPrimaryColor;
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: kDefaultPadding / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

class PopupMenuExample extends StatefulWidget {
  final VoidCallback reactCallback;
  final VoidCallback replyCallback;
  const PopupMenuExample({
    super.key,
    required this.reactCallback,
    required this.replyCallback,
  });

  @override
  State<PopupMenuExample> createState() => _PopupMenuExampleState();
}

enum SampleItem { itemReact, itemReply }

class _PopupMenuExampleState extends State<PopupMenuExample> {
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      //initialValue: selectedMenu,
      // Callback that sets the selected popup menu item.
      // onSelected: (SampleItem item) {
      //   setState(() {
      //     selectedMenu = item;
      //   });
      // },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        PopupMenuItem<SampleItem>(
          //value: SampleItem.itemReact,
          child: ReactWidget(
            reactCallback: widget.reactCallback,
          ),
        ),
        PopupMenuItem<SampleItem>(
          //value: SampleItem.itemReply,
          child: ReplyWidget(
            replyCallback: widget.replyCallback,
          ),
        ),
      ],
    );
  }
}
