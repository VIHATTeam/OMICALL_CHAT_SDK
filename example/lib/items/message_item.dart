import 'package:flutter/material.dart';
import 'package:livetalk_sdk/entity/live_talk_message_entity.dart';
import 'package:livetalk_sdk_example/datetime_helper.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.data,
  });

  final LiveTalkMessageEntity data;

  @override
  Widget build(BuildContext context) {
    if (data.memberType == "system") {
      return systemMessage;
    }
    return Row(
      mainAxisAlignment: data.memberType != "guest"
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
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
              color: data.memberType != "guest" ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
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
            "${DateTimeHelper.timestampToString(data.lastUpdatedDate ?? 0)} Khách đã để lại thông tin",
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
