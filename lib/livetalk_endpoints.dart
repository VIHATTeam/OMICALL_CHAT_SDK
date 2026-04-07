/// Central registry for all LiveTalk API base URLs and endpoint paths.
/// Update [baseUrl] or [socketUrl] here to switch environments.
abstract final class LiveTalkEndpoints {
  // ---------------------------------------------------------------------------
  // Base URLs
  // ---------------------------------------------------------------------------

  static const String baseUrl   = 'https://livetalk-v2-stg.omicrm.com/widget';
  static const String socketUrl = 'https://socket-event-v1-stg.omicrm.com';

  // ---------------------------------------------------------------------------
  // Config
  // ---------------------------------------------------------------------------

  /// GET config for a domain. Append /{domainPbx} when calling.
  static const String config = '/config/get_v2';

  // ---------------------------------------------------------------------------
  // Room
  // ---------------------------------------------------------------------------

  static const String createRoom    = '/new_room_v2';
  static const String getCurrentRoom = '/guest/room_v2'; // append /{room_id}

  // ---------------------------------------------------------------------------
  // Messaging
  // ---------------------------------------------------------------------------

  static const String sendMessage   = '/message/guest_send_message_v2';
  static const String sendSticker   = '/message/sticker/guest_send_v2';
  static const String sendMedia     = '/message/guest_send_media_v2';
  static const String messageHistory = '/message/search_for_guest_v2'; // ?page=&size=
  static const String removeMessage  = '/guest/message/remove_v2';
  static const String actionOnMessage = '/guest/message/sender_action_v2';

  // ---------------------------------------------------------------------------
  // Session / Device
  // ---------------------------------------------------------------------------

  static const String logout = '/guest/device_info/remove_v2';

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  static const String geo = '/geo_v2';
}
