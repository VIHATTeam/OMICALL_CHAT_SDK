import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk_example/audio_preview.dart';
import 'package:livetalk_sdk_example/datetime_helper.dart';
import 'package:livetalk_sdk_example/extensions/string_extension.dart';
import 'package:livetalk_sdk_example/image_preview.dart';
import 'package:livetalk_sdk_example/video_preview.dart';

class RepMessageItem extends StatelessWidget {
  const RepMessageItem({
    super.key,
    required this.data,
  });

  final LiveTalkMessageEntity data;

  @override
  Widget build(BuildContext context) {
    return chatMessage(context);
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
        children: [
          fileWidget,
        ],
      );
    }
    return Row(
      mainAxisAlignment:MainAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
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
              child: Text(
                data.content ?? "",
                style: TextStyle(
                  fontSize: 16,
                  color:
                  data.memberType != "guest" ? Colors.black : Colors.white,
                ),
              ),
            ),
            if (data.reactions?.isNotEmpty == true)
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 16,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Text(
                        data.reactions![index].reaction ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 1,
                      );
                    },
                    itemCount:
                    data.reactions!.length > 5 ? 5 : data.reactions!.length,
                  ),
                ),
              )
          ],
        ),
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
}
