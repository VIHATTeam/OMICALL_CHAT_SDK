# Migration Guide — v0.0.15 → v1.0.1

## Breaking Changes

---

### 1. `LiveTalkError` — constructor & fields changed

**Before (v0.0.15):**
```dart
// Constructor accepted a single optional dynamic field
LiveTalkError({ this.message }) // message is dynamic

// Usage in catch block:
} on LiveTalkError catch (e) {
  final msg = e.message["message"]; // e.g. "empty_info", "invalid_phone"
}
```

**After (v1.0.1):**
```dart
// Constructor now requires statusCode + errorKey
LiveTalkError({
  required this.statusCode, // int: HTTP code, 0 = API body error, -1 = client error
  required this.errorKey,   // String: one of LiveTalkErrorCodes.*
  this.message,             // Map<String, dynamic>? — raw server payload, debugging only
})

// Usage in catch block:
} on LiveTalkError catch (e) {
  final key      = e.errorKey;   // e.g. LiveTalkErrorCodes.invalidPhone
  final httpCode = e.statusCode; // e.g. 400, -1
}
```

**Migration:**

| Old | New |
|-----|-----|
| `e.message["message"]` | `e.errorKey` |
| `LiveTalkError(message: {...})` | `LiveTalkError(statusCode: -1, errorKey: LiveTalkErrorCodes.xxx)` |

> `errorKey` values are i18n-friendly string constants defined in `LiveTalkErrorCodes`. Use them as keys in your translation table.

---

### 2. `createRoom()` — `domain` parameter type changed

**Before (v0.0.15):**
```dart
await LiveTalkSdk.shareInstance.createRoom(
  phone:       '0123456789',
  fullName:    'Nguyen Van A',
  uuid:        '0123456789',
  autoExpired: false,
  fcm:         'fcm-token',
  projectId:   'project-id',
  domain:      'https://omicall.com', // full URL string
);
```

**After (v1.0.1):**
```dart
await LiveTalkSdk.shareInstance.createRoom(
  phone:       '0123456789',
  fullName:    'Nguyen Van A',
  uuid:        '0123456789',
  autoExpired: false,           // unchanged
  fcm:         'fcm-token',     // unchanged
  projectId:   'project-id',    // unchanged
  domain:      'default',       // ← short name, not a URL (V2 API spec)
);
```

**Migration:** Change `domain` value from a full URL (e.g. `'https://omicall.com'`) to a short domain name (e.g. `'default'`). All other parameters remain the same.

---

## Non-Breaking Changes (informational)

### New: `LiveTalkErrorCodes` class

All error key constants in one place. Use instead of hardcoding strings:

```dart
LiveTalkErrorCodes.invalidPhone     // 'error_invalid_phone'
LiveTalkErrorCodes.sessionExpired   // 'error_session_expired'
LiveTalkErrorCodes.noInternet       // 'error_no_internet'
// ... see livetalk_error_codes.dart for full list
```

### New: `LiveTalkEndpoints` class

All API base URLs and paths in one place. Change environment by updating `LiveTalkEndpoints.baseUrl`:

```dart
import 'package:livetalk_sdk/livetalk_endpoints.dart';

print(LiveTalkEndpoints.baseUrl);   // https://livetalk-v2-stg.omicrm.com/widget
print(LiveTalkEndpoints.socketUrl); // https://socket-event-v1-stg.omicrm.com
```

### New: `uploadFileStream` error event includes `error_key`

When `status == 4` (upload failed), the event now includes an `error_key` field:

```dart
LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
  if (event['status'] == 4) {
    final errorKey = event['error_key'] as String?; // LiveTalkErrorCodes.*
  }
});
```

### API paths migrated to V2

All endpoints now call V2 paths (e.g. `/new_room_v2`, `/guest_send_message_v2`). No action required — transparent to SDK consumers.

---

## Quick Checklist

- [ ] Replace all `e.message["message"]` → `e.errorKey` in catch blocks
- [ ] Replace `LiveTalkError(message: {...})` with `LiveTalkError(statusCode: ..., errorKey: ...)` if you throw errors manually
- [ ] Change `domain` in `createRoom()` from URL → short name (e.g. `'default'`)
- [ ] (Optional) Replace hardcoded error strings with `LiveTalkErrorCodes.*` constants
