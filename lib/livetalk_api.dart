import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'entity/live_talk_message_entity.dart';

class LiveTalkApi {
  LiveTalkApi._();

  static final instance = LiveTalkApi._();
  Map<String, String>? _sdkInfo;

  Map<String, String>? get sdkInfo => _sdkInfo;
  final String _baseUrl = 'https://livetalk-v2-stg.omicrm.com/widget';

  Future<Map<String, dynamic>?> getConfig(String domainPbx) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/config/get/$domainPbx'),
    );
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
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
  }

  Future<String?> createRoom({
    required Map<String, dynamic> body,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/new_room'),
    );
    request.body = json.encode(body);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      final payload = jsonData["payload"];
      _sdkInfo!["uuid"] = payload["conversation"]["uuid"];
      _sdkInfo!["room_id"] = payload["conversation"]["_id"];
      _sdkInfo!["access_token"] = payload["login_token"]["access_token"];
      _sdkInfo!["refresh_token"] = payload["login_token"]["refresh_token"];
      return payload["conversation"]["_id"];
    }
    return null;
  }

  Future<bool> sendMessage({required String message}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/message/guest_send_message'),
    );
    request.body = json.encode({
      "content": message,
      "uuid": _sdkInfo!["uuid"],
      "room_id": _sdkInfo!["room_id"],
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      debugPrint(jsonData.toString());
      return true;
    }
    return false;
  }

  Future<bool> sendFiles({required List<String> paths}) async {
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
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      debugPrint(jsonData.toString());
      return true;
    }
    return false;
  }

  Future<List<LiveTalkMessageEntity>> getMessageHistory({
    required int page,
    int size = 15,
  }) async {
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
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      final items = jsonData["payload"]["items"] as List;
      debugPrint(items.toString());
      return List.generate(items.length, (index) => LiveTalkMessageEntity.fromJson(items[index]));
    }
    return [];
  }

  Future<bool> removeMessage({required String id}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/user/message/remove/$id'),
    );
    request.body = json.encode({
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send().catchError((error) {
      debugPrint(error.toString());
    });
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      debugPrint(jsonData.toString());
      return true;
    }
    return false;
  }
}
