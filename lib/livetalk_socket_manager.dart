import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livetalk_sdk/entity/entity.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

class LiveTalkSocketManager {
  LiveTalkSocketManager._();

  static LiveTalkSocketManager? _instance;

  static LiveTalkSocketManager get shareInstance {
    _instance ??= LiveTalkSocketManager._();
    return _instance!;
  }

  final StreamController<LiveTalkEventEntity> _eventController =
      StreamController<LiveTalkEventEntity>.broadcast();

  Stream<LiveTalkEventEntity> get eventStream => _eventController.stream;
  io.Socket? _socket;

  Future<void> startListenWebSocket(
    String token,
    String id,
    String tenantId,
  ) async {
    _socket = io.io(
      'https://socket-event-v1-stg.omicrm.com/$tenantId',
      OptionBuilder().setTransports(['websocket']).setQuery({
        "env": "widget",
        "type": "guest",
        "room_id": id,
        "token": token,
      }).build(),
    );
    _socket!.connect();
    _socket!.onConnect((data) {
      _eventController.sink.add(
        const LiveTalkEventEntity(
          eventName: "socket_connected",
        ),
      );
    });
    _socket!.on("message", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "message",
          data: detail,
        ),
      );
    });
    _socket!.on("lt_reaction", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "lt_reaction",
          data: detail,
        ),
      );
    });
    _socket!.on("member_join", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "member_join",
          data: detail,
        ),
      );
    });
    _socket!.on("member_connect", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add(LiveTalkEventEntity(
        eventName: "member_connect",
        data: jsonData,
      ));
    });
    _socket!.on("remove_message", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "member_connect",
          data: detail,
        ),
      );
    });
    _socket!.on("member_disconnect", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "member_disconnect",
          data: jsonData,
        ),
      );
    });
    _socket!.on("new_member", (data) {
      debugPrint("new_member event");
    });
    _socket!.on("someone_typing", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add(
        LiveTalkEventEntity(
          eventName: "someone_typing",
          data: jsonData,
        ),
      );
    });
    _socket!.onError((data) {
      _eventController.sink.add(
        const LiveTalkEventEntity(
          eventName: "socket_connect_error",
          data: null,
        ),
      );
    });
  }

  disconnect() {
    _socket!.disconnect();
    _socket = null;
  }
}
