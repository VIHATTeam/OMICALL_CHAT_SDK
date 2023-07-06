# LIVETALK SDK FOR Flutter

### Status
Currently active maintenance and improve performance


### Running
Install via pubspec.yaml:

```
livetalk_sdk: ^latest_version
```

### Configuration

- Add this line into main function:

```
LiveTalkSdk(domainPbx: "${your domain => provide by Omi, contact my sales to receive it}");
- If you implemented omikit_flutter_plugin. Your domain is `realm` in omikit_flutter_plugin.
```

- We use <a href="https://github.com/fluttercommunity/flutter_uploader">flutter_uploader</a> to upload files. You need see it to config on your project.

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
   await LiveTalkSdk.shareInstance.sendMessage(
      sendingMessage
   );
} catch (error) {
    if (error is LiveTalkError) {
    }
}

Parameters:
- paths: path of files
Notes:
- We limited 50 mb for each file sending.
- You can send image/video,word,pdf...... file type. We can support all.
- If result is OK, you will receive event from socket.
- New change: We will return `taskId` in result. You can use it to compare with callback and update UI.
```

- Listen file sending response:
```
final subscription = LiveTalkSdk.shareInstance.uploadFileStream.listen((event) {
});
Notes: 
- we will return status, taskId, and data
- status: UploadTaskStatus by flutter_uploader
- taskId: use compare with initial id
- data: if result is success, data is message.
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