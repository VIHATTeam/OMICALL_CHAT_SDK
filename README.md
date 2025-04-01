# LIVETALK SDK FOR Flutter

### Status
Currently active maintenance and improve performance


### Running
Install via pubspec.yaml [livetalk_sdk](https://pub.dev/packages/livetalk_sdk):

```
livetalk_sdk: ^latest_version
```

### Configuration

- Add this line into main function:

```
LiveTalkSdk(domainPbx: "${your domain => provide by Omi, contact my sales to receive it}");
- If you implemented omikit_flutter_plugin. Your domain is `realm` in omikit_flutter_plugin.
```

- We use <a href="https://pub.dev/packages/firebase_messaging">firebase_messaging</a> to show notification. You need setup it.

## Implement
- Create the room for chat:
```
try {
  EasyLoading.show();
  final result = await LiveTalkSdk.shareInstance.createRoom(
    phone: _phoneController.text,
    fullName: _userNameController.text,
    uuid: _phoneController.text,
    autoExpired: _isAutoExpired,
    fcm: // token fcm,
    projectId: // project id off firebase
  );
  EasyLoading.dismiss();
  if (result != null && mounted) {
    //navigate to chat screen.
  }
} catch (error) {
  EasyLoading.dismiss();
  if (error is LiveTalkError) {
    //have some error
    //error.message["message"] to receive error message.
  }
}

- fullname: user name.
- phone: user phone.
- autoExpired: default is false. If autoExpired is true, the room is alive only 1 day.
- uuid: unique id.
- domain: your domain, it will show on web admin
- fcm: FCM token
- projectId: your project id in firebase 
=> We need provide phone/uuid unique for each user.
=> If you change another uuid for user, we will create a new room.
=> If user don't have a room on my server, we will create a new room, if user room is exists, we will return current user room.
```
- Get current room information:
```
await LiveTalkSdk.shareInstance.getCurrentRoom();

Important fields: 
+ id: it is room id.
+ guestInfo: guest information (sdk user is guest user)
+ lastMessage: last message in current room.
+ members: room members, you can get name and status of users in this.
+ hasMember: true => admin joined on web admin, true => wait admin to join.
```
- Get chat history:
```
await LiveTalkSdk.shareInstance.getMessageHistory(
  page: page, //1,2,3,4,5
  size: size, //size of each page.
);

Important fields: 
+ id: message id.
+ uuid: user uuid.
+ createBy: message owner.
+ create date: 
+ type: chat/activity.
+ memberType: guest is user sdk/ user is admin user (on web admin)/ system is system user.
+ guestInfo: guest information (sdk user is guest user).
+ multimedias: medias file.
+ template: activity data.
+ quoteMessage: answer/quote of this message.
+ reactions: reaction list on this message.
```
- Send message:
```
final sendingMessage = LiveTalkSendingMessage.createTxtSendMessage(
  message: _controller.text, 
  quoteId: _repMessage?.id, 
);
try {
    await LiveTalkSdk.shareInstance.sendMessage(
        sendingMessage
    );
    _controller.clear();
} catch (error) {
    if (error is LiveTalkError) {
    
    }
}

Parameters:
- message: message content (only text).
- quoteId: if you want to answer/quote another message, you need send id of quote message.
=> If result is OK, you will receive event from socket.
```

- Send files:
```
final sendingMessage = LiveTalkSendingMessage.createTxtSendFiles(
  paths: result.paths.cast<String>(),
);
try {
   final result = await LiveTalkSdk.shareInstance.sendMessage(
      sendingMessage
   );
   // Result will contain task_id for tracking upload progress
   print("File upload started with task_id: ${result?["task_id"]}");
} catch (error) {
    if (error is LiveTalkError) {
      // Handle error
    }
}

Parameters:
- paths: path of files
Notes:
- We limited 50 mb for each file sending.
- You can send image/video,word,pdf...... file type. We can support all.
- If result is OK, you will receive event from socket.
- When sending files, API will return result with `task_id` key (not taskId). You can use it to identify upload tasks when handling events from uploadFileStream.
```

- Listen file sending response:
```dart
final subscription = LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
  // Example of event data:
  // {
  //   "task_id": "abc123xyz", // Task ID to identify the upload
  //   "status": 2, // Status codes: 2: in progress, 3: completed, 4: error
  //   "progress": 0.65, // Upload progress as a fraction (0.0 to 1.0)
  //   "message": "error message" // Only present when status is 4 (error)
  // }
  
  int status = event["status"];
  String? task_id = event["task_id"];
  
  if (status == 2) { // In progress
    // Update progress UI
    final progress = event["progress"] as double;
    print("Upload progress for $task_id: ${(progress * 100).toStringAsFixed(0)}%");
  } else if (status == 3) { // Completed
    // Handle completed upload
    print("Upload $task_id completed successfully");
  } else if (status == 4) { // Error
    // Handle error
    final errorMessage = event["message"];
    print("Upload $task_id failed: $errorMessage");
  }
});

Notes: 
- Status codes: 2 = in progress, 3 = completed, 4 = error
- Progress is reported as a fraction between 0.0 and 1.0
- task_id is used to identify which upload the event belongs to
```

- Remove message:
```
await LiveTalkSdk.shareInstance.removeMessage(id: id);

Parameters:
- id: message id.
- If result is OK, you will receive event from socket.
```

- React/Unreact message:
```
await LiveTalkSdk.shareInstance.actionOnMessage(
  content: content,
  id: id ?? "",
  action: "REACT",
);

Parameters:
- id: message id.
- content: reaction content.
- action: "REACT" is react on message, "UNREACT" is unreact on message.
```

- Websocket events:
```
LiveTalkSdk.shareInstance.eventStream.listen((result) {
   final event = result.eventName;
   final data = result.data;
});

With:
- event: event name.
- data: event data.
```

- Events:
  -  `message`: have a new message. You will receive message data in data field. Message data is same type with `getMessageHistory` api.
  - `someone_typing`: admin is typing/untyping message. We send `isTyping` into data field. You use to show typing/untyping.
  - `member_join`: admin joined guest chat => you need refresh room information.
  - `member_disconnect`: admin offlined.
  - `member_connect`: admin online.
  - `lt_reaction`: have reaction on message. We will send `msg_id` and `reactions` in data field, you use to find and update on your message list.
  - `remove_message`: a message removed. We will send `message_id` in data fields, you use to find and remove it on your message list.
```

# OMICALL Chat SDK

This SDK helps your application integrate easily with Omicall's LiveTalk chat platform.

## Library Versions

The SDK uses these main libraries with the following versions:
- socket_io_client: ^2.0.3+1
- http: ^1.2.1
- uuid: ^4.3.3
- dio: ^5.4.2
- device_info_plus: ^9.1.2
- package_info_plus: ^5.0.1
- Firebase Messaging: ^14.7.10 (for push notifications)
- Firebase Core: ^2.24.2

## Configuration

### Required configuration files not included in git

This project uses `.gitignore` to exclude specific configuration files that should not be included in version control. Before you can run the project, you need to ensure the following configuration files:

#### Android
- `example/android/app/google-services.json` - Firebase configuration file for Android
- `example/android/local.properties` - SDK path configuration for Android

#### iOS
- `example/ios/Runner/GoogleService-Info.plist` - Firebase configuration file for iOS
- `example/ios/firebase_app_id_file.json` - Firebase application ID (optional)

### Requirements

- Flutter 3.10.0 or later
- Dart 3.0.0 or later (Fully compatible with Dart 3)
- Android SDK 34 or later (targetSdkVersion & compileSdkVersion)
- iOS 12.0 or later

### Installation Instructions

1. Add the SDK to your `pubspec.yaml` file:

```yaml
dependencies:
  livetalk_sdk:
    git:
      url: https://github.com/VIHATTeam/OMICALL_CHAT_SDK.git
      ref: main  # or use a specific tag/branch
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase (if you want to use push notifications):

- Register your application on [Firebase Console](https://console.firebase.google.com/)
- Add your Android and iOS application to the Firebase project
- Download and add configuration files to the project:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS

4. Android Configuration:
   
Add to `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // ...
        minSdkVersion 21
        // ...
    }
}
```

5. iOS Configuration:

Update `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Usage

### Initialize SDK

```dart
import 'package:livetalk_sdk/livetalk_sdk.dart';

// Initialize SDK with your domain
LiveTalkSdk(domainPbx: "your_domain");
```

### Create a New Chat Room

```dart
try {
  final result = await LiveTalkSdk.shareInstance.createRoom(
    phone: "0123456789",  // User's phone number
    fullName: "John Doe",  // User's name
    uuid: "unique-identifier",  // Unique identifier for the user
    fcm: fcmToken,  // FCM token for push notifications (optional)
  );
  
  if (result != null) {
    print("Room created successfully with ID: $result");
  }
} catch (e) {
  print("Error creating room: $e");
}
```

### Send Message

```dart
final message = LiveTalkSendingMessage(
  roomId: roomId,  // Room ID from createRoom
  content: "Hello!",  // Message content
  type: "text",  // Message type: "text", "image", "file", ...
);

try {
  final result = await LiveTalkSdk.shareInstance.sendMessage(message);
  print("Message sent successfully: $result");
} catch (e) {
  print("Error sending message: $e");
}
```

### Receive Messages and Events

```dart
LiveTalkSdk.shareInstance.eventStream.listen((result) {
  final event = result.eventName;
  final data = result.data;
  
  switch (event) {
    case "message":
      print("New message received: $data");
      break;
    case "someone_typing":
      print("User is typing: $data");
      break;
    // Handle other events...
  }
});
```

### Receive Push Notifications (Firebase)

Use `NotificationService` to receive and process push notifications:

```dart
// Initialize notification service
await NotificationService().init();

// Register background message handler
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Handle messages when app is open
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  NotificationService().showNotification(message);
});

// Handle when user taps on notification
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Handle app opening from notification
});
```

## Troubleshooting

### Issues with compileSdkVersion

If you encounter errors related to `compileSdkVersion`, try adding the following to `gradle.properties`:

```
android.suppressUnsupportedCompileSdk=35
```

### "flutter_local_notifications" Compatibility Error

This SDK no longer depends on `flutter_local_notifications`. If your project is using this library, ensure you're using a version compatible with your Flutter version.

### Firebase "Default FirebaseApp" Error

If you encounter the "Default FirebaseApp is not initialized" error, make sure you have called:

```dart
await Firebase.initializeApp();
```

before using any Firebase features.

### Android Build Errors with Flutter

If you encounter Android build errors, try:

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
```

## API

### Messages

- `createRoom` - Create a new chat room
- `sendMessage` - Send a message
- `actionOnMessage` - Perform an action on a message (reaction)
- `removeMessage` - Delete a message
- `getMessageHistory` - Get message history

### Events

- `message` - New message available
- `someone_typing` - Admin is typing/stopped typing
- `member_join` - Admin joined the conversation
- `member_disconnect` - Admin offline
- `member_connect` - Admin online
- `lt_reaction` - Message reaction received
- `remove_message` - Message deleted

## License

Copyright © 2024 VIHAT Solution

[License details]
