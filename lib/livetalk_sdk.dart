import 'dart:async';

import 'package:livetalk_sdk/entity/live_talk_room_entity.dart';
import 'package:livetalk_sdk/entity/livetalk_error.dart';
import 'package:livetalk_sdk/livetalk_api.dart';
import 'package:livetalk_sdk/livetalk_socket_manager.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';

import 'entity/live_talk_message_entity.dart';

class LiveTalkSdk {
  final String domainPbx;
  static LiveTalkSdk? _instance;

  static LiveTalkSdk get shareInstance => _instance!;
  final String fileUrl = 'https://cdn.omicrm.com/crm/';

  LiveTalkSdk({required this.domainPbx}) {
    LiveTalkApi.instance.getConfig(domainPbx);
    _instance = this;
  }

  Stream<dynamic> get eventStream =>
      LiveTalkSocketManager.shareInstance.eventStream;

  Future<String?> createRoom({
    required String phone,
    required String fullName,
    required String uuid,
    String? domain,
    String? address,
    String? ip,
    double? lat,
    double? long,
  }) async {
    try {
      final sdkInfo = LiveTalkApi.instance.sdkInfo;
      if (sdkInfo == null) {
        throw LiveTalkError(message: {"message": "empty_info"});
      }
      if (phone.isValidMobilePhone == false) {
        throw LiveTalkError(message: {"message": "invalid_phone"});
      }
      final body = {
        "uuid": uuid,
        "start_type": "script",
        "tenant_id": sdkInfo["tenant_id"],
        "auto_expired": false,
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
          "address": address ?? "Vietnam",
          "ip": ip ?? "",
          "lat": lat ?? 0,
          "lon": long ?? 0
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

  Future<bool> sendMessage({required String message, String? quoteId}) async {
    return await LiveTalkApi.instance.sendMessage(
      message: message,
      quoteId: quoteId,
    );
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

  Future<bool> sendFiles({required List<String> paths}) async {
    return await LiveTalkApi.instance.sendFiles(paths: paths);
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
