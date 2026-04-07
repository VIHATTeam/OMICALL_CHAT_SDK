import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:livetalk_sdk/livetalk_api.dart';
import 'package:livetalk_sdk/livetalk_error_codes.dart';
import 'package:livetalk_sdk/livetalk_socket_manager.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'entity/entity.dart';

class LiveTalkSdk {
  final String domainPbx;
  static LiveTalkSdk? _instance;

  static LiveTalkSdk get shareInstance => _instance!;

  /// Base URL for file/media assets served from CDN.
  final String fileUrl = 'https://cdn.omicrm.com/crm/';

  Timer? _limitTimer;

  Stream<Map<String, dynamic>> get uploadFileStream =>
      LiveTalkApi.instance.uploadStream;

  LiveTalkSdk({required this.domainPbx}) {
    LiveTalkApi.instance.getConfig(domainPbx);
    _instance = this;
  }

  Stream<LiveTalkEventEntity> get eventStream =>
      LiveTalkSocketManager.shareInstance.eventStream;

  // ---------------------------------------------------------------------------
  // Room
  // ---------------------------------------------------------------------------

  /// Creates a chat room (V2 API).
  /// [uuid] should be a stable unique identifier for this guest session.
  /// [domain] defaults to 'default' as per V2 API spec.
  /// [fcm] FCM device token for push notifications.
  /// [projectId] optional project ID for routing.
  /// [autoExpired] whether the room auto-expires when inactive.
  Future<String?> createRoom({
    required String phone,
    required String fullName,
    required String uuid,
    String domain = 'default',
    bool autoExpired = false,
    String? fcm,
    String? projectId,
  }) async {
    var sdkInfo = LiveTalkApi.instance.sdkInfo;
    if (sdkInfo == null) {
      sdkInfo = await LiveTalkApi.instance.getConfig(domainPbx);
      if (sdkInfo == null) {
        throw LiveTalkError(
          statusCode: -1,
          errorKey: LiveTalkErrorCodes.emptyInfo,
        );
      }
    }

    if (!phone.isValidMobilePhone) {
      throw LiveTalkError(
        statusCode: -1,
        errorKey: LiveTalkErrorCodes.invalidPhone,
      );
    }

    // Collect device info for push notification routing
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    String deviceId = '';
    String deviceType = '';
    if (deviceInfo is IosDeviceInfo) {
      deviceId   = deviceInfo.identifierForVendor ?? '';
      deviceType = 'IOS';
    } else if (deviceInfo is AndroidDeviceInfo) {
      deviceId   = deviceInfo.id;
      deviceType = 'ANDROID';
    }

    final packageName = (await PackageInfo.fromPlatform()).packageName;

    // Attempt geo lookup — non-fatal if it fails
    LiveTalkGeoEntity? geo;
    try {
      geo = await LiveTalkApi.instance.getGeo();
      debugPrint('[LiveTalkSdk] Geo OK: ${geo?.geopluginRequest} / ${geo?.geopluginRegion}');
    } catch (e) {
      debugPrint('[LiveTalkSdk] Geo fetch failed (non-fatal): $e');
    }

    final body = {
      'tenant_id':    sdkInfo['tenant_id'],
      'uuid':         uuid,
      'app_id':       packageName,
      'start_type':   'script',
      'auto_expired': autoExpired,
      'project_id':   projectId ?? '',
      'device_info': {
        'device_id':   deviceId,
        'token':       fcm,
        'device_type': deviceType,
        'voip_token':  '',
        'app_env':     kDebugMode ? '2' : '1',
      },
      'guest_info': {
        'uuid':      uuid,
        'phone':     phone,
        'full_name': fullName,
        'domain':    domain,
        if (geo != null) ...{
          // Build address from non-null parts only
          'address': [
            geo.geopluginCity ?? geo.geopluginRegion ?? geo.geopluginRegionName,
            geo.geopluginCountryName,
          ].where((p) => p != null && p.isNotEmpty).join(' - '),
          if (geo.geopluginRequest != null) 'ip':  geo.geopluginRequest,
          if (geo.geopluginLatitude != null) 'lat': geo.geopluginLatitude,
          if (geo.geopluginLongitude != null) 'lon': geo.geopluginLongitude,
        },
      },
    };

    final roomId = await LiveTalkApi.instance.createRoom(body: body);

    if (roomId != null) {
      LiveTalkSocketManager.shareInstance.startListenWebSocket(
        LiveTalkApi.instance.sdkInfo!['access_token'] as String,
        roomId,
        sdkInfo['tenant_id'] as String,
      );
    }

    return roomId;
  }

  Future<LiveTalkRoomEntity?> getCurrentRoom() async {
    return LiveTalkApi.instance.getCurrentRoom();
  }

  // ---------------------------------------------------------------------------
  // Messaging
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> sendMessage(LiveTalkSendingMessage message) async {
    if (_limitTimer != null) {
      throw LiveTalkError(
        statusCode: -1,
        errorKey: LiveTalkErrorCodes.spamRequest,
      );
    }
    _limitTimer = Timer(const Duration(milliseconds: 300), () {});
    try {
      final result = await LiveTalkApi.instance.sendMessage(message);
      _limitTimer?.cancel();
      _limitTimer = null;
      return result;
    } catch (_) {
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
    return LiveTalkApi.instance.actionOnMessage(
      content: content,
      id: id,
      action: action,
    );
  }

  Future<bool> removeMessage({required String id}) async {
    return LiveTalkApi.instance.removeMessage(id: id);
  }

  Future<List<LiveTalkMessageEntity>> getMessageHistory({
    required int page,
    int size = 15,
  }) async {
    return LiveTalkApi.instance.getMessageHistory(page: page, size: size);
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<bool> logout(String uuid) async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    String deviceId = '';
    if (deviceInfo is IosDeviceInfo) {
      deviceId = deviceInfo.identifierForVendor ?? '';
    } else if (deviceInfo is AndroidDeviceInfo) {
      deviceId = deviceInfo.id;
    }

    final packageName = (await PackageInfo.fromPlatform()).packageName;

    return LiveTalkApi.instance.logout(
      appId:    packageName,
      deviceId: deviceId,
      uuid:     uuid,
    );
  }

  void disconnect() {
    LiveTalkSocketManager.shareInstance.disconnect();
  }

  Future<void> forceReconnectSocket() async {
    try {
      final currentRoom = await getCurrentRoom();
      if (currentRoom?.id == null) return;

      LiveTalkSocketManager.shareInstance.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));

      final sdkInfo = LiveTalkApi.instance.sdkInfo;
      if (sdkInfo?['access_token'] != null && sdkInfo?['tenant_id'] != null) {
        LiveTalkSocketManager.shareInstance.startListenWebSocket(
          sdkInfo!['access_token'] as String,
          currentRoom!.id!,
          sdkInfo['tenant_id'] as String,
        );
      }
    } catch (_) {
      rethrow;
    }
  }
}
