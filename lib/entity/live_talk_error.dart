import 'package:livetalk_sdk/livetalk_error_codes.dart';

class LiveTalkError extends Error {
  /// HTTP status code (e.g. 400, 500).
  /// 0  → API body error (status_code: -9999, transport succeeded).
  /// -1 → client-side / pre-request validation error.
  final int statusCode;

  /// One of [LiveTalkErrorCodes] constants.
  /// Use this key to look up localized messages in the app's i18n table.
  final String errorKey;

  /// Raw server response payload, if available. Use for logging / debugging only.
  final Map<String, dynamic>? message;

  LiveTalkError({
    required this.statusCode,
    required this.errorKey,
    this.message,
  });

  @override
  String toString() =>
      'LiveTalkError(statusCode: $statusCode, errorKey: $errorKey, message: $message)';
}
