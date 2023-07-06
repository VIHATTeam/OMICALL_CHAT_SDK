import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:livetalk_sdk/livetalk_api.dart';
import 'package:livetalk_sdk/livetalk_socket_manager.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'entity/entity.dart';

void backgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterUploader uploader = FlutterUploader();
  uploader.result.listen((result) {
    _processMessage(result);
  });
}

void _processMessage(UploadTaskResponse result) {
  final taskId = result.taskId;
  final status = result.status;
  final data = result.response;
  Map<String, dynamic>? message;
  if (data != null && status == UploadTaskStatus.complete) {
    message = jsonDecode(data);
  }
  _sendMessageController.add({
    "status": status?.value ?? 0,
    "taskId": taskId,
    "message": message,
  });
}

final StreamController<Map<String, dynamic>> _sendMessageController =
    StreamController.broadcast();

class LiveTalkSdk {
  final String domainPbx;
  static LiveTalkSdk? _instance;

  static LiveTalkSdk get shareInstance => _instance!;
  final String fileUrl = 'https://cdn.omicrm.com/crm/';
  Timer? _limitTimer;

  // UploadFileCallback? uploadFileProcess;
  Stream<Map<String, dynamic>> get uploadFileStream =>
      _sendMessageController.stream;

  LiveTalkSdk({required this.domainPbx}) {
    LiveTalkApi.instance.getConfig(domainPbx);
    _instance = this;
    FlutterUploader().setBackgroundHandler(backgroundHandler);
    FlutterUploader().result.listen((result) {
      _processMessage(result);
    });
  }

  Stream<LiveTalkEventEntity> get eventStream =>
      LiveTalkSocketManager.shareInstance.eventStream;

  Future<String?> createRoom({
    required String phone,
    required String fullName,
    required String uuid,
    bool autoExpired = false,
    String? domain,
  }) async {
    try {
      var sdkInfo = LiveTalkApi.instance.sdkInfo;
      if (sdkInfo == null) {
        sdkInfo = await LiveTalkApi.instance.getConfig(domainPbx);
        if (sdkInfo == null) {
          throw LiveTalkError(message: {"message": "empty_info"});
        }
      }
      if (phone.isValidMobilePhone == false) {
        throw LiveTalkError(message: {"message": "invalid_phone"});
      }
      final geo = await LiveTalkApi.instance.getGeo();
      if (geo == null) {
        throw LiveTalkError(message: {"message": "invalid_ip"});
      }
      final body = {
        "uuid": uuid,
        "start_type": "script",
        "tenant_id": sdkInfo["tenant_id"],
        "auto_expired": autoExpired,
        "guest_info": {
          "uuid": uuid,
          "phone": phone,
          "email": "",
          "full_name": fullName,
          "other_info": {
            "full_name": fullName,
            "phone_number": phone,
            "mail": ""
          },
          "domain": domain ?? "https://omicall.com",
          "browser": "",
          "address": "${geo.geopluginRegion} - ${geo.geopluginCountryName}",
          "ip": geo.geopluginRequest ?? "",
          "lat": geo.geopluginLatitude,
          "lon": geo.geopluginLongitude,
        }
      };
      final result = await LiveTalkApi.instance.createRoom(body: body);
      //trigger websocket
      if (result != null) {
        LiveTalkSocketManager.shareInstance.startListenWebSocket(
          LiveTalkApi.instance.sdkInfo!["access_token"] as String,
          result,
          sdkInfo["tenant_id"] as String,
        );
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<LiveTalkRoomEntity?> getCurrentRoom() async {
    return await LiveTalkApi.instance.getCurrentRoom();
  }

  Future<Map<String, dynamic>?> sendMessage(
      LiveTalkSendingMessage message) async {
    if (_limitTimer != null) {
      throw LiveTalkError(message: {
        "message": "spam_error",
      });
    }
    _limitTimer = Timer(const Duration(milliseconds: 300), () {});
    try {
      final result = await LiveTalkApi.instance.sendMessage(message);
      _limitTimer?.cancel();
      _limitTimer = null;
      return result;
    } catch (error) {
      _limitTimer?.cancel();
      _limitTimer = null;
      rethrow;
    }
  }

  Future<bool> actionOnMessage({
    required String content,
    required String id,
    required String action,
  }) async {
    return await LiveTalkApi.instance.actionOnMessage(
      content: content,
      id: id,
      action: action,
    );
  }

  Future<bool> removeMessage({
    required String id,
  }) async {
    return await LiveTalkApi.instance.removeMessage(id: id);
  }

  Future<List<LiveTalkMessageEntity>> getMessageHistory({
    required int page,
    int size = 15,
  }) async {
    return await LiveTalkApi.instance.getMessageHistory(
      page: page,
      size: size,
    );
  }

  void disconnect() {
    LiveTalkSocketManager.shareInstance.disconnect();
  }
}
