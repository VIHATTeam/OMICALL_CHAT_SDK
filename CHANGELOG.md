# Changelog

All notable changes to this project will be documented in this file.

## 1.0.1 — 2026-04-07

### Breaking Changes
- `createRoom()` signature simplified: removed `autoExpired`, `fcm`, `projectId`, `domain` (URL) parameters. V2 API no longer requires geo-location or device info. New signature: `createRoom({ phone, fullName, uuid, domain = 'default' })`.
- `LiveTalkError` constructor changed: now requires `statusCode` (int) and `errorKey` (String). Old `message`-only constructor no longer valid. Update catch blocks to use `error.errorKey` for i18n lookups.

### New Features
- **Centralized endpoint management** — `LiveTalkEndpoints` class (`lib/livetalk_endpoints.dart`) holds all API base URLs and paths. Change environment or update a path in one place.
- **Structured error handling** — `LiveTalkErrorCodes` class (`lib/livetalk_error_codes.dart`) defines string constants for all HTTP status codes (204, 301, 304, 400–429, 440, 500–511) plus API body errors and client-side validation errors. Designed for i18n: pass `error.errorKey` to your translation layer.
- **`LiveTalkError` now carries `statusCode` and `errorKey`** — consumers can `switch` on `statusCode` or match `errorKey` against `LiveTalkErrorCodes.*` constants.
- Upload progress stream events now include `error_key` field (one of `LiveTalkErrorCodes.*`) when `status == 4`.

### API Paths Updated to V2
All endpoints migrated to V2:
- `POST /widget/new_room_v2`
- `POST /widget/message/guest_send_message_v2`
- `POST /widget/message/sticker/guest_send_v2`
- `POST /widget/message/guest_send_media_v2`
- `POST /widget/message/search_for_guest_v2`
- `POST /widget/guest/message/remove_v2`
- `POST /widget/guest/device_info/remove_v2`
- `POST /widget/new_room_v2` success indicator changed: `status_code: 9999` (was `0`)

### Android
- `compileSdk` and `targetSdk` upgraded to **36** (required by `flutter_plugin_android_lifecycle`, `image_picker_android`, `path_provider_android`, `video_player_android`).
- `minSdk` set to **23** (Flutter 3.35+ minimum).
- Fixed Kotlin DSL (`build.gradle.kts`) syntax: `minSdkVersion flutter.minSdkVersion` → `minSdk = 23`.

### Dependencies
- `device_info_plus` upgraded to `^11.0.0` (fixes `win32` 4.x → 5.x transitive dependency, required for Dart 3.9+).
- `package_info_plus` upgraded to `^8.0.0`.
- Dart SDK constraint updated to `>=3.5.0 <4.0.0`.
- Flutter constraint updated to `>=3.24.0`.

## 0.0.12, 0.0.14, 0.0.15
- Standardized documentation to match API implementation
- Fixed inconsistencies in parameter naming (task_id vs taskId)
- Clarified file upload status codes (2=in progress, 3=completed, 4=error)
- Updated examples in README to accurately reflect API response format
- Improved file upload documentation with clearer examples

## 0.0.11
- Update SDK environment from '>=2.14.0 <3.0.0' to '>=2.14.0 <4.0.0' for Dart 3 compatibility
- Replace flutter_uploader with Dio for file uploads, removing external dependency
- Improve file upload handling and progress monitoring
- Remove unnecessary print statements to improve performance
- Improve socket connection handling and stability
- Enhance error handling in API requests
- Standardize socket event naming
- Fix socket initialization with proper disposal of previous connections
- Optimize code for better SDK integration
- Fix potential memory leaks in socket connections

## 0.0.10
- Update params create room
- Add show notification at example 

## 0.0.9
- Upgrade version socket.io to V2 

## 0.0.8
- Remove firebase_message

## 0.0.7
- Support message notification
- Update document and sample

## 0.0.6
- Support to upload files on background
- Return message 
- Update document and sample

## 0.0.5
- We limit timer for message sending
- Change content-type image
- Refresh config information

## 0.0.4
- Allow to send sticker

## 0.0.3
- Fix cast error on 3.3.10

## 0.0.2
- Update sending and receive model

## 0.0.1
* Release basic version. 