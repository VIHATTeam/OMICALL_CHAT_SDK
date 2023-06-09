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
      _eventController.sink.add({
        "event": "socket_connected",
      });
    });
    _socket!.on("message", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add({
        "event": "message",
        "data": LiveTalkMessageEntity.fromJson(detail),
      });
    });
    _socket!.on("lt_reaction", (data) {
      final jsonData = json.decode(data);
      final detail = json.decode(jsonData["detail"]);
      _eventController.sink.add({
        "event": "lt_reaction",
        "data": detail,
      });
    });
    _socket!.on("member_join", (data) {
      final jsonData = json.decode(data);
      final detail = jsonData["detail"];
      final detailJson = json.decode(detail);
      _eventController.sink.add({
        "event": "member_join",
        "data": detailJson,
      });
    });
    _socket!.on("member_connect", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add({
        "event": "member_connect",
        "data": jsonData,
      });
    });
    _socket!.on("remove_message", (data) {
      final jsonData = json.decode(data);
      final detail = jsonData["detail"];
      final detailJson = json.decode(detail);
      _eventController.sink.add({
        "event": "remove_message",
        "data": detailJson,
      });
    });
    _socket!.on("member_disconnect", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add({
        "event": "member_disconnect",
        "data": jsonData,
      });
    });
    _socket!.on("new_member", (data) {
      debugPrint("new_member event");
    });
    _socket!.on("someone_typing", (data) {
      final jsonData = json.decode(data);
      _eventController.sink.add({
        "event": "someone_typing",
        "data": jsonData,
      });
    });
    _socket!.onError((data) {
      _eventController.sink.add({
        "event": "socket_connect_error",
      });
    });
  }

  disconnect() {
    _socket!.disconnect();
    _socket = null;
  }
}
