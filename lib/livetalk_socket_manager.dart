import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livetalk_sdk/entity/live_talk_message_entity.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

class LiveTalkSocketManager {
  LiveTalkSocketManager._();

  static LiveTalkSocketManager? _instance;

  static LiveTalkSocketManager get shareInstance {
    _instance ??= LiveTalkSocketManager._();
    return _instance!;
  }

  final StreamController _eventController = StreamController.broadcast();
  Stream<dynamic> get eventStream => _eventController.stream;

  Future<void> startListenWebSocket(
    String token,
    String id,
    String tenantId,
  ) async {
    io.Socket socket = io.io(
      'https://socket-event-v1-stg.omicrm.com/$tenantId',
      OptionBuilder().setTransports(['websocket']).setQuery({
        "env": "widget",
        "type": "guest",
        "room_id": id,
        "token": token,
      }).build(),
    );
    socket.connect();
    socket.onConnect((data) {
      debugPrint("connected");
    });
    socket.on("message", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add({
        "event": "message",
        "data": LiveTalkMessageEntity.fromJson(detail),
      });
    });
    socket.onError((data) {
      debugPrint(data.toString());
    });
  }
}
