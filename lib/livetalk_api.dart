import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livetalk_sdk/livetalk_file_utils.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'entity/entity.dart';

class LiveTalkApi {
  LiveTalkApi._();

  static final instance = LiveTalkApi._();
  Map<String, String>? _sdkInfo;

  Map<String, String>? get sdkInfo => _sdkInfo;
  final String _baseUrl = 'https://livetalk-v2-stg.omicrm.com/widget';

  Future<Map<String, dynamic>?> getConfig(String domainPbx) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/config/get/$domainPbx'),
      );
      request.body = json.encode({});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if ((response.statusCode ~/ 100) > 2) {
        throw LiveTalkError(message: {"message": response.reasonPhrase});
      }
      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = json.decode(data);
        if (jsonData["status_code"] == -9999) {
          throw LiveTalkError(message: jsonData);
        }
        final payload = jsonData["payload"];
        final tentantId = payload["tenant_id"];
        final accessToken = payload["token"]["access_token"];
        final refreshToken = payload["token"]["refresh_token"];
        _sdkInfo = {
          "tenant_id": tentantId,
          "access_token": accessToken,
          "refresh_token": refreshToken,
        };
        return _sdkInfo;
      }
      return null;
    } catch (error) {
      rethrow;
    }
  }

  Future<String?> createRoom({
    required Map<String, dynamic> body,
  }) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/new_room'),
      );
      request.body = json.encode(body);
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if ((response.statusCode ~/ 100) > 2) {
        throw LiveTalkError(message: {"message": response.reasonPhrase});
      }
      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = json.decode(data);
        if (jsonData["status_code"] == -9999) {
          throw LiveTalkError(message: jsonData);
        }
        final payload = jsonData["payload"];
        _sdkInfo!["uuid"] = payload["conversation"]["uuid"];
        _sdkInfo!["room_id"] = payload["conversation"]["_id"];
        _sdkInfo!["access_token"] = payload["login_token"]["access_token"];
        _sdkInfo!["refresh_token"] = payload["login_token"]["refresh_token"];
        return payload["conversation"]["_id"];
      }
      return null;
    } catch (error) {
      rethrow;
    }
  }

  Future<LiveTalkRoomEntity?> getCurrentRoom() async {
    try {
      if (sdkInfo == null) {
        throw LiveTalkError(message: {"message": "empty_info"});
      }
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
      };
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl//guest/room/${_sdkInfo!["room_id"]}'),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if ((response.statusCode ~/ 100) > 2) {
        throw LiveTalkError(message: {"message": response.reasonPhrase});
      }
      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = json.decode(data);
        if (jsonData["status_code"] == -9999) {
          throw LiveTalkError(message: jsonData);
        }
        final payload = jsonData["payload"];
        return LiveTalkRoomEntity.fromJson(payload);
      }
      return null;
    } catch (error) {
      rethrow;
    }
  }


  Future<bool> sendMessage(LiveTalkSendingMessage message) async {
    final messageTxt = message.message;
    final quoteId = message.quoteId;
    final paths = message.paths;
    if (messageTxt != null) {
      return _sendText(message: messageTxt, quoteId: quoteId);
    }
    if (paths != null) {
      return _sendFiles(paths: paths);
    }
    return false;
  }

  Future<bool> _sendText({
    required String message,
    String? quoteId,
  }) async {
    if (sdkInfo == null) {
      throw LiveTalkError(message: {"message": "empty_info"});
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/message/guest_send_message'),
    );
    final body = {
      "content": message.encode,
      "uuid": _sdkInfo!["uuid"],
      "room_id": _sdkInfo!["room_id"],
    };
    if (quoteId != null) {
      body["quote_id"] = quoteId;
    }
    request.body = json.encode(body);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      return true;
    }
    return false;
  }

  Future<bool> actionOnMessage({
    required String content,
    required String id,
    required String action,
  }) async {
    if (sdkInfo == null) {
      throw LiveTalkError(message: {"message": "empty_info"});
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/guest/message/sender_action'),
    );
    request.body = json.encode({
      "content": content,
      "uuid": _sdkInfo!["uuid"],
      "ref_id": id,
      "room_id": _sdkInfo!["room_id"],
      "action": action,
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      return true;
    }
    return false;
  }

  Future<bool> _sendFiles({required List<String> paths}) async {
    if (sdkInfo == null) {
      throw LiveTalkError(message: {"message": "empty_info"});
    }
    if (paths.isEmpty == true) {
      return true;
    }
    final files = paths.map((e) => File(e)).toList();
    final totalSize = files.fold<double>(
      0.0,
      (previousValue, element) => previousValue + element.fileSize,
    );
    if (totalSize > 100) {
      throw LiveTalkError(message: {"message": "limit_100mb"});
    }
    var headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/message/guest_send_media'),
    );
    for (var path in paths) {
      request.files.add(await http.MultipartFile.fromPath('files', path));
    }
    request.fields.addAll({
      "uuid": _sdkInfo!["uuid"] ?? "",
      "room_id": _sdkInfo!["room_id"] ?? "",
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send().timeout(
      const Duration(seconds: 600),
      onTimeout: () {
        throw throw LiveTalkError(message: "timeout");
      },
    );
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      return true;
    }
    return false;
  }

  Future<List<LiveTalkMessageEntity>> getMessageHistory({
    required int page,
    int size = 15,
  }) async {
    if (sdkInfo == null) {
      throw LiveTalkError(message: {"message": "empty_info"});
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/message/search_for_guest?page=$page&size=$size'),
    );
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      final items = jsonData["payload"]["items"] as List;
      return List.generate(items.length,
          (index) => LiveTalkMessageEntity.fromJson(items[index]));
    }
    return [];
  }

  Future<bool> removeMessage({required String id}) async {
    if (sdkInfo == null) {
      throw LiveTalkError(message: {"message": "empty_info"});
    }
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/guest/message/remove'),
    );
    request.body = json.encode({
      "room_id": _sdkInfo!["room_id"] ?? "",
      "message_id": id,
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      return true;
    }
    return false;
  }

  Future<LiveTalkGeoEntity?> getGeo() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'GET',
      Uri.parse('$_baseUrl/geo'),
    );
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if ((response.statusCode ~/ 100) > 2) {
      throw LiveTalkError(message: {"message": response.reasonPhrase});
    }
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      if (jsonData["status_code"] == -9999) {
        throw LiveTalkError(message: jsonData);
      }
      final payload = json.decode(jsonData["payload"]);
      final result = LiveTalkGeoEntity.fromJson(payload);
      return result;
    }
    return null;
  }
}
