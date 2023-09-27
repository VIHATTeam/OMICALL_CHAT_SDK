import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk_example/extensions/string_extension.dart';

import '../../../audio_preview.dart';
import '../../../constants.dart';
import '../../../image_preview.dart';
import '../../../video_preview.dart';

class FileMessage extends StatelessWidget {
  final LiveTalkMessageEntity message;
  const FileMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = message.multimedias![index];
          if (message.type == "sticker") {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  item.url ?? "",
                ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.75,
                vertical: kDefaultPadding / 2,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor
                    .withOpacity(message.memberType == "guest" ? 1 : 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_present_rounded,
                    size: 24,
                    color: message.memberType == "guest"
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      item.name ?? "",
                      style: TextStyle(
                        color: message.memberType == "guest"
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge!.color,
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
        itemCount: message.multimedias!.length,
      ),
    );
  }
}
