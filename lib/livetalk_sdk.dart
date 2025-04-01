import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livetalk_sdk/livetalk_api.dart';
import 'package:livetalk_sdk/livetalk_socket_manager.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'entity/entity.dart';

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
      LiveTalkApi.instance.uploadStream;

  LiveTalkSdk({required this.domainPbx}) {
    LiveTalkApi.instance.getConfig(domainPbx);
    _instance = this;
  }

  Stream<LiveTalkEventEntity> get eventStream =>
      LiveTalkSocketManager.shareInstance.eventStream;

  Future<String?> createRoom({
    required String phone,
    required String fullName,
    required String uuid,
    bool autoExpired = false,
    String? domain,
    String? fcm,
    String? projectId
  }) async {
    try {
      var sdkInfo = LiveTalkApi.instance.sdkInfo;
      if (sdkInfo == null) {
        sdkInfo = await LiveTalkApi.instance.getConfig(domainPbx);
        if (sdkInfo == null) {
          print('❌ SDK Info is empty');
          throw LiveTalkError(message: {"message": "empty_info"});
        }
      } else {
      }
      
      if (phone.isValidMobilePhone == false) {
        print('❌ Invalid phone number: $phone');
        throw LiveTalkError(message: {"message": "invalid_phone"});
      }
      
      final geo = await LiveTalkApi.instance.getGeo();
      if (geo == null) {
        print('❌ Failed to get geolocation data');
        throw LiveTalkError(message: {"message": "invalid_ip"});
      }
      
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      String id = "";
      if (deviceInfo is IosDeviceInfo) {
        id = deviceInfo.identifierForVendor ?? "";
      }
      if (deviceInfo is AndroidDeviceInfo) {
        id = deviceInfo.id;
      }
      
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageName = packageInfo.packageName;

      String projectIdTemp = "";
      
      if (projectId != null && projectId.isNotEmpty) {
        projectIdTemp = projectId;
      }
      
      final body = {
        "uuid": uuid,
        "start_type": "script",
        "tenant_id": sdkInfo["tenant_id"],
        "auto_expired": autoExpired,
        "app_id": packageName,
        "project_id": projectIdTemp,
        "device_info": {
          "device_id": id,
          "token": fcm,
          "device_type": Platform.isIOS ? "IOS" : "ANDROID",
          "voip_token": "",
          "app_env": kDebugMode ? "2" : "1",
        },
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
      
      if (result != null) {
        LiveTalkSocketManager.shareInstance.startListenWebSocket(
          LiveTalkApi.instance.sdkInfo!["access_token"] as String,
          result,
          sdkInfo["tenant_id"] as String,
        );
      } else {
        print('⚠️ Room created but result is null');
      }
      
      return result;
    } catch (error) {
      print('❌ Error in LiveTalkSdk.createRoom: $error');
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

  Future<bool> logout(String uuid) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    String id = "";
    if (deviceInfo is IosDeviceInfo) {
      id = deviceInfo.identifierForVendor ?? "";
    }
    if (deviceInfo is AndroidDeviceInfo) {
      id = deviceInfo.id;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    return LiveTalkApi.instance.logout(
      appId: packageName,
      deviceId: id,
      uuid: uuid,
    );
  }

  void disconnect() {
    LiveTalkSocketManager.shareInstance.disconnect();
  }

  Future<void> forceReconnectSocket() async {
    try {
      print("💡 Force reconnecting socket...");
      LiveTalkRoomEntity? currentRoom = await getCurrentRoom();
      if (currentRoom != null && currentRoom.id != null) {
        print("💡 Using room ID: ${currentRoom.id}");
        LiveTalkSocketManager.shareInstance.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
        
        final sdkInfo = LiveTalkApi.instance.sdkInfo;
        if (sdkInfo != null && sdkInfo["access_token"] != null && sdkInfo["tenant_id"] != null) {
          print("💡 Reconnecting socket with token and tenant ID");
          LiveTalkSocketManager.shareInstance.startListenWebSocket(
            sdkInfo["access_token"] as String,
            currentRoom.id!,
            sdkInfo["tenant_id"] as String,
          );
          return;
        }
        print("💡 Can't reconnect: missing SDK info");
      } else {
        print("💡 No active room found");
      }
    } catch (e) {
      print("💡 Error during force reconnect: $e");
      rethrow;
    }
  }
}
