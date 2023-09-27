import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';

import '../../../constants.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    this.message,
  }) : super(key: key);

  final LiveTalkMessageEntity? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color:
            kPrimaryColor.withOpacity(message!.memberType == "guest" ? 1 : 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        (message!.content ?? "").decode,
        style: TextStyle(
          color: message!.memberType == "guest"
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
    );
  }
}
