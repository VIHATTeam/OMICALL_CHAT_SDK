import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String message,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Notification"),
        content: Text(message),
      );
    },
  );
}
