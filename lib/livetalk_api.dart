import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:livetalk_sdk/livetalk_endpoints.dart';
import 'package:livetalk_sdk/livetalk_error_codes.dart';
import 'package:livetalk_sdk/livetalk_file_utils.dart';
import 'package:livetalk_sdk/livetalk_string_utils.dart';
import 'package:uuid/uuid.dart';

import 'entity/entity.dart';

class LiveTalkApi {
  LiveTalkApi._();

  static final instance = LiveTalkApi._();

  Map<String, String>? _sdkInfo;
  final Dio _dio = Dio();
  final StreamController<Map<String, dynamic>> _uploadProgressController =
      StreamController<Map<String, dynamic>>.broadcast();
  final Uuid _uuidGenerator = const Uuid();

  Stream<Map<String, dynamic>> get uploadStream =>
      _uploadProgressController.stream;

  Map<String, dynamic>? get sdkInfo => _sdkInfo;

  String get _base => LiveTalkEndpoints.baseUrl;
  String get _uuid => _uuidGenerator.v4();

  // ---------------------------------------------------------------------------
  // Error helpers
  // ---------------------------------------------------------------------------

  static LiveTalkError _httpError(int statusCode, String? reasonPhrase) {
    final key = switch (statusCode) {
      204 => LiveTalkErrorCodes.noData,
      301 => LiveTalkErrorCodes.movedPermanently,
      304 => LiveTalkErrorCodes.notModified,
      400 => LiveTalkErrorCodes.invalidData,
      401 => LiveTalkErrorCodes.sessionExpired,
      402 => LiveTalkErrorCodes.paymentRequired,
      403 => LiveTalkErrorCodes.forbidden,
      404 => LiveTalkErrorCodes.notFound,
      405 => LiveTalkErrorCodes.methodNotAllowed,
      406 => LiveTalkErrorCodes.outOfArea,
      407 => LiveTalkErrorCodes.proxyAuthRequired,
      408 => LiveTalkErrorCodes.requestTimeoutHttp,
      409 => LiveTalkErrorCodes.conflict,
      410 => LiveTalkErrorCodes.gone,
      411 => LiveTalkErrorCodes.lengthRequired,
      412 => LiveTalkErrorCodes.preconditionFailed,
      413 => LiveTalkErrorCodes.payloadTooLarge,
      414 => LiveTalkErrorCodes.uriTooLong,
      415 => LiveTalkErrorCodes.unsupportedMediaType,
      416 => LiveTalkErrorCodes.rangeNotSatisfiable,
      422 => LiveTalkErrorCodes.unprocessableEntity,
      429 => LiveTalkErrorCodes.tooManyRequests,
      440 => LiveTalkErrorCodes.loginSessionExpired,
      500 => LiveTalkErrorCodes.system,
      501 => LiveTalkErrorCodes.notImplemented,
      502 => LiveTalkErrorCodes.badGateway,
      503 => LiveTalkErrorCodes.serviceUnavailable,
      504 => LiveTalkErrorCodes.requestTimeout,
      505 => LiveTalkErrorCodes.httpVersionNotSupp,
      507 => LiveTalkErrorCodes.insufficientStorage,
      511 => LiveTalkErrorCodes.noInternet,
      _   => LiveTalkErrorCodes.unknown,
    };
    return LiveTalkError(
      statusCode: statusCode,
      errorKey: key,
      message: reasonPhrase != null ? {'message': reasonPhrase} : null,
    );
  }

  static LiveTalkError _apiBodyError(Map<String, dynamic> jsonData) {
    return LiveTalkError(
      statusCode: 0,
      errorKey: LiveTalkErrorCodes.api,
      message: Map<String, dynamic>.from(jsonData),
    );
  }

  static LiveTalkError _clientError(String errorKey, {String? detail}) {
    return LiveTalkError(
      statusCode: -1,
      errorKey: errorKey,
      message: detail != null ? {'detail': detail} : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Config
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getConfig(String domainPbx) async {
    try {
      final response = await http.post(
        Uri.parse('$_base${LiveTalkEndpoints.config}/$domainPbx'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode != 200) {
        throw _httpError(response.statusCode, response.reasonPhrase);
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

      final payload = jsonData['payload'] as Map<String, dynamic>;
      final token   = payload['token']    as Map<String, dynamic>;
      _sdkInfo = {
        'tenant_id':     payload['tenant_id']     as String,
        'access_token':  token['access_token']    as String,
        'refresh_token': token['refresh_token']   as String,
      };
      return _sdkInfo;
    } catch (_) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Room
  // ---------------------------------------------------------------------------

  /// POST /new_room_v2 — V2 success: status_code == 9999.
  /// [body] is the full request payload built by the caller (LiveTalkSdk).
  Future<String?> createRoom({required Map<String, dynamic> body}) async {
    try {

      final response = await http.post(
        Uri.parse('$_base${LiveTalkEndpoints.createRoom}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw _httpError(response.statusCode, response.reasonPhrase);
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);
      // V2 uses 9999 for success; tolerate legacy 0 as well
      if (jsonData['status_code'] != 9999 && jsonData['status_code'] != 0) {
        throw _apiBodyError(jsonData);
      }

      final payload      = jsonData['payload']     as Map<String, dynamic>;
      final conversation = payload['conversation'] as Map<String, dynamic>;
      final loginToken   = payload['login_token']  as Map<String, dynamic>;

      _sdkInfo ??= {};
      _sdkInfo!['tenant_id']     = body['tenant_id'] as String;
      _sdkInfo!['uuid']          = conversation['uuid']             as String;
      _sdkInfo!['room_id']       = conversation['_id']              as String;
      _sdkInfo!['access_token']  = loginToken['access_token']       as String;
      _sdkInfo!['refresh_token'] = loginToken['refresh_token']      as String;

      return conversation['_id'] as String?;
    } catch (_) {
      rethrow;
    }
  }

  Future<LiveTalkRoomEntity?> getCurrentRoom() async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final request = http.Request(
      'GET',
      Uri.parse('$_base${LiveTalkEndpoints.getCurrentRoom}/${_sdkInfo!["room_id"]}'),
    )..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      });

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return LiveTalkRoomEntity.fromJson(jsonData['payload'] as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Send message — dispatcher
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> sendMessage(LiveTalkSendingMessage message) async {
    if (message.sticker    != null) return _sendSticker(sticker: message.sticker!);
    if (message.message    != null) return _sendText(message: message.message!, quoteId: message.quoteId);
    if (message.paths      != null) return _sendFiles(paths: message.paths!);
    return null;
  }

  // ---------------------------------------------------------------------------
  // Send text
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _sendText({
    required String message,
    String? quoteId,
  }) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);
    if (message.trim().isEmpty) throw _clientError(LiveTalkErrorCodes.emptyText);

    final body = <String, String>{
      'content': message.encode,
      'uuid':    _uuid,
      'room_id': _sdkInfo!['room_id']!,
    };
    if (quoteId != null) body['quote_id'] = quoteId;

    final request = http.Request(
      'POST',
      Uri.parse('$_base${LiveTalkEndpoints.sendMessage}'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      })
      ..body = json.encode(body);

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return jsonData['payload'] as Map<String, dynamic>?;
  }

  // ---------------------------------------------------------------------------
  // Send sticker
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _sendSticker({required String sticker}) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final body = {
      'type':    'guest',
      'url':     sticker,
      'uuid':    _uuid,
      'room_id': _sdkInfo!['room_id'],
    };

    final request = http.Request(
      'POST',
      Uri.parse('$_base${LiveTalkEndpoints.sendSticker}'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      })
      ..body = json.encode(body);

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return jsonData['payload'] as Map<String, dynamic>?;
  }

  // ---------------------------------------------------------------------------
  // Send files / media
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _sendFiles({required List<String> paths}) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);
    if (paths.isEmpty)    throw _clientError(LiveTalkErrorCodes.emptyPaths);
    if (paths.length > 6) throw _clientError(LiveTalkErrorCodes.fileLimitExceeded);

    final totalSize = paths.map((e) => File(e)).fold<double>(
      0.0, (prev, f) => prev + f.fileSize,
    );
    if (totalSize > 50) throw _clientError(LiveTalkErrorCodes.fileSizeExceeded);

    try {
      final formData = FormData()
        ..fields.add(MapEntry('uuid',    _uuid))
        ..fields.add(MapEntry('room_id', _sdkInfo!['room_id'] ?? ''));

      for (final path in paths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: File(path).path.split('/').last),
        ));
      }

      final taskId = _uuid;

      _dio.post(
        '$_base${LiveTalkEndpoints.sendMedia}',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
        }),
        onSendProgress: (sent, total) {
          _uploadProgressController.add({
            'task_id':  taskId,
            'status':   (sent / total) >= 1.0 ? 3 : 2,
            'progress': sent / total,
          });
        },
      ).then((response) {
        if (response.statusCode == 200) {
          final jsonData = response.data as Map<String, dynamic>;
          if (jsonData['status_code'] == -9999) {
            _uploadProgressController.add({
              'task_id':   taskId,
              'status':    4,
              'error_key': LiveTalkErrorCodes.api,
              'message':   jsonData['message'] ?? '',
            });
          } else {
            _uploadProgressController.add({'task_id': taskId, 'status': 3});
          }
        } else {
          _uploadProgressController.add({
            'task_id':   taskId,
            'status':    4,
            'error_key': LiveTalkErrorCodes.system,
            'message':   'Server error: ${response.statusCode}',
          });
        }
      }).catchError((error) {
        _uploadProgressController.add({
          'task_id':   taskId,
          'status':    4,
          'error_key': LiveTalkErrorCodes.unknown,
          'message':   error.toString(),
        });
      });

      return {'task_id': taskId};
    } catch (e) {
      throw _clientError(LiveTalkErrorCodes.unknown, detail: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Action on message
  // ---------------------------------------------------------------------------

  Future<bool> actionOnMessage({
    required String content,
    required String id,
    required String action,
  }) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final request = http.Request(
      'POST',
      Uri.parse('$_base${LiveTalkEndpoints.actionOnMessage}'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      })
      ..body = json.encode({
        'content': content,
        'uuid':    _uuid,
        'ref_id':  id,
        'room_id': _sdkInfo!['room_id'],
        'action':  action,
      });

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return true;
  }

  // ---------------------------------------------------------------------------
  // Message history
  // ---------------------------------------------------------------------------

  Future<List<LiveTalkMessageEntity>> getMessageHistory({
    required int page,
    int size = 15,
  }) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final request = http.Request(
      'POST',
      Uri.parse('$_base${LiveTalkEndpoints.messageHistory}?page=$page&size=$size'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      })
      ..body = json.encode({});

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    final items = jsonData['payload']['items'] as List;
    return List.generate(
      items.length,
      (i) => LiveTalkMessageEntity.fromJson(items[i] as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // Remove message
  // ---------------------------------------------------------------------------

  Future<bool> removeMessage({required String id}) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final request = http.Request(
      'POST',
      Uri.parse('$_base${LiveTalkEndpoints.removeMessage}'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      })
      ..body = json.encode({
        'room_id':    _sdkInfo!['room_id'] ?? '',
        'message_id': id,
      });

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw _httpError(streamed.statusCode, streamed.reasonPhrase);
    }

    final data     = await streamed.stream.bytesToString();
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return true;
  }

  // ---------------------------------------------------------------------------
  // Geo
  // ---------------------------------------------------------------------------

  Future<LiveTalkGeoEntity?> getGeo() async {
    try {
      final response = await http.get(
        Uri.parse('$_base${LiveTalkEndpoints.geo}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw _httpError(response.statusCode, response.reasonPhrase);
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

      final payload = json.decode(jsonData['payload'] as String);
      return LiveTalkGeoEntity.fromJson(payload as Map<String, dynamic>);
    } catch (_) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<bool> logout({
    required String appId,
    required String deviceId,
    required String uuid,
  }) async {
    if (_sdkInfo == null) throw _clientError(LiveTalkErrorCodes.emptyInfo);

    final response = await http.post(
      Uri.parse('$_base${LiveTalkEndpoints.logout}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_sdkInfo!["access_token"]}',
      },
      body: json.encode({
        'app_id':    appId,
        'device_id': deviceId,
        'uuid':      uuid,
      }),
    );

    if (response.statusCode != 200) {
      throw _httpError(response.statusCode, response.reasonPhrase);
    }

    final jsonData = json.decode(response.body) as Map<String, dynamic>;
    if (jsonData['status_code'] == -9999) throw _apiBodyError(jsonData);

    return true;
  }
}
