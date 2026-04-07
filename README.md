# OMICALL Chat SDK for Flutter

Flutter SDK for integrating [Omicall LiveTalk](https://omicall.com) chat into mobile applications.

[![pub.dev](https://img.shields.io/pub/v/livetalk_sdk.svg)](https://pub.dev/packages/livetalk_sdk)

---

## Requirements

| Platform | Minimum version |
|----------|----------------|
| Flutter  | 3.16.0         |
| Dart     | 3.2.0          |
| Android  | SDK 23 (Android 6.0) |
| iOS      | 12.0           |

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  livetalk_sdk: ^1.0.1
```

Then run:

```bash
flutter pub get
```

---

## Android Setup

In `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = 36

    defaultConfig {
        minSdk = 23
        targetSdk = 36
    }
}
```

In `android/gradle.properties`:

```properties
android.suppressUnsupportedCompileSdk=36
```

---

## iOS Setup

In `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

---

## Firebase Push Notifications (Optional)

The SDK does not require Firebase, but push notifications need it.

1. Register your app at [Firebase Console](https://console.firebase.google.com/).
2. Add `google-services.json` to `android/app/`.
3. Add `GoogleService-Info.plist` to `ios/Runner/`.
4. Add dependencies to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.3
```

5. Initialize in `main.dart`:

```dart
await Firebase.initializeApp();
FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
```

---

## Quick Start

### 1. Initialize SDK

Call once in `main()` before `runApp()`:

```dart
import 'package:livetalk_sdk/livetalk_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LiveTalkSdk(domainPbx: 'your_domain'); // domain provided by Omicall
  runApp(const MyApp());
}
```

> `domainPbx` is the same as `realm` if you are using `omikit_flutter_plugin`.

### 2. Create a Chat Room

```dart
try {
  final roomId = await LiveTalkSdk.shareInstance.createRoom(
    phone:    '0123456789',   // guest phone number
    fullName: 'Nguyen Van A', // guest display name
    uuid:     '0123456789',   // unique identifier — reuse to resume the same room
    domain:   'default',      // optional, defaults to 'default'
  );

  if (roomId != null) {
    // navigate to chat screen
  }
} on LiveTalkError catch (e) {
  // e.errorKey: i18n key (e.g. 'error_invalid_phone')
  // e.statusCode: HTTP status code or -1 for client errors
  print('Error: ${e.errorKey}');
}
```

> - Same `uuid` → resumes existing room.
> - Different `uuid` → creates a new room.

### 3. Send a Text Message

```dart
final msg = LiveTalkSendingMessage.createTxtSendMessage(
  message: 'Hello!',
  quoteId: replyMessageId, // optional — quote/reply another message
);

try {
  await LiveTalkSdk.shareInstance.sendMessage(msg);
} on LiveTalkError catch (e) {
  print('Error: ${e.errorKey}');
}
```

### 4. Send a Sticker

```dart
final msg = LiveTalkSendingMessage.createSendSticker(
  sticker: 'https://example.com/sticker.png', // sticker URL
);

await LiveTalkSdk.shareInstance.sendMessage(msg);
```

### 5. Send Files / Media

```dart
final msg = LiveTalkSendingMessage.createTxtSendFiles(
  paths: ['/path/to/file1.jpg', '/path/to/file2.pdf'],
);

final result = await LiveTalkSdk.shareInstance.sendMessage(msg);
final taskId = result?['task_id']; // use to track upload progress
```

**Limits:** max 6 files, total ≤ 50 MB. Supports image, video, PDF, Word, and all common file types.

### 6. Track Upload Progress

```dart
LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
  final taskId   = event['task_id']  as String;
  final status   = event['status']   as int;
  final progress = event['progress'] as double?; // 0.0–1.0, only when status == 2

  switch (status) {
    case 2: // uploading
      print('$taskId — ${((progress ?? 0) * 100).toStringAsFixed(0)}%');
    case 3: // completed
      print('$taskId — done');
    case 4: // error
      final errorKey = event['error_key'] as String?; // LiveTalkErrorCodes.*
      print('$taskId — failed: $errorKey');
  }
});
```

### 7. Listen for Real-Time Events

```dart
LiveTalkSdk.shareInstance.eventStream.listen((event) {
  switch (event.eventName) {
    case 'message':
      // event.data contains the new message (same shape as getMessageHistory items)
      break;
    case 'someone_typing':
      // event.data['isTyping'] — bool
      break;
    case 'member_join':
      // agent joined — refresh room info with getCurrentRoom()
      break;
    case 'member_connect':
      // agent came online
      break;
    case 'member_disconnect':
      // agent went offline
      break;
    case 'lt_reaction':
      // event.data['msg_id'], event.data['reactions']
      break;
    case 'remove_message':
      // event.data['message_id']
      break;
    case 'socket_connected':
    case 'socket_disconnect':
    case 'socket_connect_error':
      break;
  }
});
```

### 8. Get Room Info

```dart
final room = await LiveTalkSdk.shareInstance.getCurrentRoom();

// Key fields:
// room.id           — room ID
// room.status       — 'active' | ...
// room.hasMember    — true: agent is present, false: waiting
// room.members      — list of agents (name, avatar, status, sipUser)
// room.lastMessage  — last message summary
// room.guestInfo    — guest (SDK user) information
```

### 9. Get Message History

```dart
final messages = await LiveTalkSdk.shareInstance.getMessageHistory(
  page: 0,   // zero-based page index
  size: 15,  // items per page
);

// Each LiveTalkMessageEntity has:
// .id           — message ID
// .content      — text content
// .type         — 'message' | 'activity' | 'sticker' | 'media'
// .memberType   — 'guest' | 'agent' | 'system'
// .multimedias  — list of attached files (name, url, contentType, size)
// .reactions    — list of reactions
// .quoteMessage — quoted/replied message
// .createdDate  — Unix timestamp (ms)
```

### 10. React / Unreact to a Message

```dart
await LiveTalkSdk.shareInstance.actionOnMessage(
  id:      messageId,
  content: '👍',
  action:  'REACT',   // or 'UNREACT'
);
```

### 11. Remove a Message

```dart
await LiveTalkSdk.shareInstance.removeMessage(id: messageId);
```

### 12. Logout

```dart
await LiveTalkSdk.shareInstance.logout(uuid);
```

### 13. Disconnect Socket

Manually close the WebSocket connection (e.g. when leaving the chat screen):

```dart
LiveTalkSdk.shareInstance.disconnect();
```

### 14. Force Reconnect Socket

Re-establish the WebSocket connection after a network drop:

```dart
await LiveTalkSdk.shareInstance.forceReconnectSocket();
```

> Internally: disconnects, waits 500 ms, then reconnects using the current room and token. No-op if no active room.

---

## Architecture Overview

```
Your App
   │
   ▼
LiveTalkSdk (singleton — LiveTalkSdk.shareInstance)
   ├── LiveTalkApi (singleton)          — REST: HTTP + Dio (file uploads)
   │     ├── POST /new_room_v2
   │     ├── POST /message/guest_send_message_v2
   │     ├── POST /message/sticker/guest_send_v2
   │     ├── POST /message/guest_send_media_v2
   │     ├── POST /message/search_for_guest_v2
   │     ├── POST /guest/message/remove_v2
   │     ├── POST /guest/message/sender_action
   │     ├── GET  /guest/room
   │     └── POST /guest/device_info/remove_v2
   │
   └── LiveTalkSocketManager (singleton) — WebSocket (socket_io_client v2)
         └── wss://socket-event-v1-stg.omicrm.com/{tenantId}
               Events: message, lt_reaction, member_join,
                       member_connect, member_disconnect,
                       someone_typing, socket_connected,
                       socket_disconnect, socket_connect_error
```

**Startup flow:**
```
LiveTalkSdk(domainPbx)
  └─▶ LiveTalkApi.getConfig(domainPbx)   ← fetches tenantId + access_token

createRoom(phone, fullName, uuid)
  └─▶ LiveTalkApi.createRoom()           ← POST /new_room_v2 → returns roomId
        └─▶ LiveTalkSocketManager.startListenWebSocket(token, roomId, tenantId)
```

---

## Error Handling

All SDK methods throw `LiveTalkError` on failure.

```dart
try {
  await LiveTalkSdk.shareInstance.createRoom(...);
} on LiveTalkError catch (e) {
  final key        = e.errorKey;    // String constant from LiveTalkErrorCodes
  final httpCode   = e.statusCode;  // HTTP code, 0 (API body error), or -1 (client error)
  final rawPayload = e.message;     // Map<String, dynamic>? — raw server response

  // Use errorKey for i18n:
  final localizedMsg = AppLocalizations.of(context)!.translate(key);
}
```

### `LiveTalkErrorCodes` reference

| Constant | HTTP code | Meaning |
|----------|-----------|---------|
| `noData` | 204 | No content |
| `invalidData` | 400 | Bad request / invalid input |
| `sessionExpired` | 401 | Token expired |
| `forbidden` | 403 | No permission |
| `notFound` | 404 | Resource not found |
| `methodNotAllowed` | 405 | Method not allowed |
| `tooManyRequests` | 429 | Rate limited |
| `loginSessionExpired` | 440 | Login session expired |
| `system` | 500 | Internal server error |
| `badGateway` | 502 | Bad gateway |
| `serviceUnavailable` | 503 | Service unavailable |
| `requestTimeout` | 504 | Gateway timeout |
| `noInternet` | 511 | No network |
| `api` | 0 | API returned status_code -9999 |
| `emptyInfo` | -1 | SDK not initialized |
| `invalidPhone` | -1 | Invalid phone number format |
| `spamRequest` | -1 | Message sent too fast (300 ms throttle) |
| `emptyText` | -1 | Empty message content |
| `fileLimitExceeded` | -1 | More than 6 files |
| `fileSizeExceeded` | -1 | Total file size > 50 MB |
| `unknown` | — | Unhandled error |

---

## Endpoint Configuration

All API base URLs and paths are defined in `LiveTalkEndpoints`:

```dart
import 'package:livetalk_sdk/livetalk_endpoints.dart';

// Read the current base URL:
print(LiveTalkEndpoints.baseUrl);   // https://livetalk-v2-stg.omicrm.com/widget
print(LiveTalkEndpoints.socketUrl); // https://socket-event-v1-stg.omicrm.com
```

To switch environments, update `lib/livetalk_endpoints.dart` — all methods pick up the change automatically.

---

## Troubleshooting

**Build error: `minSdkVersion flutter.minSdkVersion` in `.kts` file**

This is a Kotlin DSL syntax error injected by older Flutter tooling. Replace with:
```kotlin
minSdk = 23
```

**`win32` package error: `UnmodifiableUint8ListView isn't a type`**

Requires `win32 >= 5.x`. Upgrade `device_info_plus` to `^11.0.0`:
```bash
flutter pub upgrade device_info_plus
```

**Android: plugins require compileSdk 36**

`flutter_plugin_android_lifecycle`, `image_picker_android`, `path_provider_android`, and `video_player_android` all require `compileSdk = 36`. Set it in `build.gradle.kts`.

**Firebase: "Default FirebaseApp is not initialized"**

Ensure `await Firebase.initializeApp()` is called before any Firebase usage in `main()`.

**Clean build after dependency changes:**

```bash
flutter clean && flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

---

## License

Copyright © 2024 VIHAT Solution. All rights reserved.
