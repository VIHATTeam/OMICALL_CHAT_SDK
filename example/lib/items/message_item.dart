import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'package:livetalk_sdk_example/audio_preview.dart';
import 'package:livetalk_sdk_example/datetime_helper.dart';
import 'package:livetalk_sdk_example/extensions/string_extension.dart';
import 'package:livetalk_sdk_example/image_preview.dart';
import 'package:livetalk_sdk_example/items/rep_message_widget.dart';
import 'package:livetalk_sdk_example/video_preview.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.data,
    this.longPress,
    this.reactCallback,
    this.replyCallback,
  });

  final LiveTalkMessageEntity data;
  final Function(String? id)? longPress;
  final Function(String? id)? reactCallback;
  final Function(String? id)? replyCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: data.memberType == "guest"
          ? () {
              if (longPress != null) {
                longPress!(data.id);
              }
            }
          : null,
      child: chatMessage(context),
    );
  }

  Widget chatMessage(BuildContext context) {
    if (data.memberType == "system") {
      return systemMessage;
    }
    if (data.multimedias?.isNotEmpty == true) {
      return Row(
        mainAxisAlignment: data.memberType != "guest"
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.memberType == "guest") ...[
            replyWidget,
            const SizedBox(
              width: 6,
            ),
            reactWidget,
            const SizedBox(
              width: 6,
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [fileWidget, reactionWidget],
          ),
          if (data.memberType != "guest") ...[
            const SizedBox(
              width: 6,
            ),
            reactWidget,
            const SizedBox(
              width: 6,
            ),
            replyWidget,
          ],
        ],
      );
    }
    return Row(
      mainAxisAlignment: data.memberType != "guest"
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (data.memberType == "guest") ...[
          replyWidget,
          const SizedBox(
            width: 6,
          ),
          reactWidget,
          const SizedBox(
            width: 6,
          ),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.quoteMessage != null) ...[
              Row(
                children: [
                  RepMessageItem(data: data.quoteMessage!),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    "Rep by",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 3 * 2,
              ),
              decoration: BoxDecoration(
                color: data.memberType != "guest" ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data.content ?? "").decode,
                    style: TextStyle(
                      fontSize: 16,
                      color: data.memberType != "guest"
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  reactionWidget
                ],
              ),
            ),
          ],
        ),
        if (data.memberType != "guest") ...[
          const SizedBox(
            width: 6,
          ),
          reactWidget,
          const SizedBox(
            width: 6,
          ),
          replyWidget
        ],
      ],
    );
  }

  Widget get fileWidget {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = data.multimedias![index];
          if (data.type == "sticker") {
            return AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                item.url ?? "",
              ),
            );
          }
          return GestureDetector(
            onTap: () {
              final file =
                  "${LiveTalkSdk.shareInstance.fileUrl}${item.url ?? ""}";
              if (file.isImage) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreview(image: file),
                    fullscreenDialog: true,
                  ),
                );
                return;
              }
              if (file.isVideo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPreview(video: file),
                    fullscreenDialog: true,
                  ),
                );
                return;
              }
              if (file.isAudio) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPreview(audio: file),
                    fullscreenDialog: true,
                  ),
                );
                return;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: data.memberType != "guest" ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_present_rounded,
                    size: 24,
                    color: data.memberType != "guest"
                        ? Colors.black
                        : Colors.white,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      item.name ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: data.memberType != "guest"
                            ? Colors.black
                            : Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 6,
          );
        },
        itemCount: data.multimedias!.length,
      ),
    );
  }

  Widget get systemMessage {
    final action = data.action;
    if (action == "create_room") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${DateTimeHelper.timestampToString(data.lastUpdatedDate ?? 0)} Bạn đã để lại thông tin",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "${data.guestInfo?.fullName ?? ""} | ${data.guestInfo?.phone ?? ""}",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
            ),
          )
        ],
      );
    }
    return Text(
      data.content ?? "",
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    );
  }

  Widget get reactWidget {
    return GestureDetector(
      child: const Icon(
        Icons.account_circle,
        color: Colors.grey,
        size: 24,
      ),
      onTap: () {
        if (reactCallback != null) {
          reactCallback!(data.id);
        }
      },
    );
  }

  Widget get replyWidget {
    return GestureDetector(
      child: const Icon(
        Icons.reply,
        color: Colors.grey,
        size: 24,
      ),
      onTap: () {
        if (replyCallback != null) {
          replyCallback!(data.id);
        }
      },
    );
  }

  Widget get reactionWidget {
    if (data.reactions?.isNotEmpty == true) {
      return SizedBox(
        height: 20,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Text(
              data.reactions![index].reaction ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 1,
            );
          },
          itemCount: data.reactions!.length > 5 ? 5 : data.reactions!.length,
        ),
      );
    }
    return const SizedBox();
  }
}
