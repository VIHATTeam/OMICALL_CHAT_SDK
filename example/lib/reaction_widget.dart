import 'package:flutter/cupertino.dart';

const reactList = ["❤️", "😀", "😊", "🥲", "🤨", "😆", "🥹", "😠", "😤"];

class ReactionWidget extends StatelessWidget {
  const ReactionWidget({
    super.key,
    required this.callback,
  });

  final Function(String context) callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              callback(reactList[index]);
            },
            child: Text(
              reactList[index],
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 12,
          );
        },
        itemCount: reactList.length,
      ),
    );
  }
}
