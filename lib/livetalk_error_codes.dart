/// String constants for all LiveTalk SDK error keys.
/// Consumers use these keys to look up localized messages in their i18n tables.
/// Never display an errorKey directly to the end user.
abstract final class LiveTalkErrorCodes {
  // --- 2xx non-success ---
  static const String noData                = 'error_no_data';                // 204 No Content

  // --- 3xx redirects (rarely thrown, included for completeness) ---
  static const String movedPermanently      = 'error_moved_permanently';      // 301
  static const String notModified           = 'error_not_modified';           // 304

  // --- 4xx client errors ---
  static const String invalidData           = 'error_invalid_data';           // 400 Bad Request
  static const String sessionExpired        = 'error_session_expired';        // 401 Unauthorized
  static const String paymentRequired       = 'error_payment_required';       // 402
  static const String forbidden             = 'error_forbidden';              // 403 Forbidden
  static const String notFound              = 'error_not_found';              // 404 Not Found
  static const String methodNotAllowed      = 'error_method_not_allowed';     // 405
  static const String outOfArea             = 'error_out_of_area';            // 406 Not Acceptable
  static const String proxyAuthRequired     = 'error_proxy_auth_required';    // 407
  static const String requestTimeoutHttp    = 'error_request_timeout_http';   // 408 Request Timeout
  static const String conflict              = 'error_conflict';               // 409
  static const String gone                  = 'error_gone';                   // 410
  static const String lengthRequired        = 'error_length_required';        // 411
  static const String preconditionFailed    = 'error_precondition_failed';    // 412
  static const String payloadTooLarge       = 'error_payload_too_large';      // 413
  static const String uriTooLong            = 'error_uri_too_long';           // 414
  static const String unsupportedMediaType  = 'error_unsupported_media_type'; // 415
  static const String rangeNotSatisfiable   = 'error_range_not_satisfiable';  // 416
  static const String unprocessableEntity   = 'error_unprocessable_entity';   // 422
  static const String tooManyRequests       = 'error_too_many_requests';      // 429

  // Non-standard / custom codes used in practice
  static const String loginSessionExpired   = 'error_login_session_expired';  // 440
  static const String noInternet            = 'error_no_internet';            // 511

  // --- 5xx server errors ---
  static const String system                = 'error_system';                 // 500 Internal Server Error
  static const String notImplemented        = 'error_not_implemented';        // 501
  static const String badGateway            = 'error_bad_gateway';            // 502
  static const String serviceUnavailable    = 'error_service_unavailable';    // 503
  static const String requestTimeout        = 'error_timeout';                // 504 Gateway Timeout
  static const String httpVersionNotSupp    = 'error_http_version_not_supported'; // 505
  static const String insufficientStorage   = 'error_insufficient_storage';   // 507

  // --- API response body error ---
  // Returned when HTTP 200 but body contains status_code: -9999
  static const String api                   = 'error_api';

  // --- Client-side / pre-request validation errors ---
  static const String emptyInfo             = 'error_empty_info';
  static const String invalidPhone          = 'error_invalid_phone';
  static const String spamRequest           = 'error_spam_request';
  static const String emptyText             = 'error_empty_text';
  static const String emptyPaths            = 'error_empty_paths';
  static const String fileLimitExceeded     = 'error_file_limit_exceeded';
  static const String fileSizeExceeded      = 'error_file_size_exceeded';

  // --- Fallback ---
  static const String unknown               = 'error_unknown';
}
