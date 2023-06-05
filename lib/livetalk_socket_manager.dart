import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class LiveTalkSocketManager {
  const LiveTalkSocketManager._();

  static LiveTalkSocketManager get instance => const LiveTalkSocketManager._();

  Future<void> startListenWebSocket(
      String token, String id, String tenantId) async {
    IO.Socket socket = IO.io(
      'https://socket-event-v1-stg.omicrm.com/$tenantId',
      OptionBuilder()
      .setTransports(['websocket'])
      .setQuery({
        "env": "widget",
        "type": "guest",
        "room_id": id,
        "token": token,
      }).build(),
    );
    socket.connect();
    socket.onConnect((data) {
      debugPrint(data.toString());
    });
    socket.on("message", (data) {
      debugPrint(data.toString());
    });
    socket.onError((data) {
      debugPrint(data.toString());
    });
  }
}
