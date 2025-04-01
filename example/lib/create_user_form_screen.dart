// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/entity/entity.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:livetalk_sdk_example/chat_screen.dart';
import 'package:livetalk_sdk_example/dialog/dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CreateUserFormScreen extends StatefulWidget {
  const CreateUserFormScreen({Key? key}) : super(key: key);

  // var phoneNumber = "";
  @override
  State<StatefulWidget> createState() {
    return _CreateUserFormState();
  }
}

String uuid = "0967884005";

class _CreateUserFormState extends State<CreateUserFormScreen> {
  //video
  late final TextEditingController _userNameController = TextEditingController()
    ..text = "N 0967884005";
  late final TextEditingController _phoneController = TextEditingController()
    ..text = uuid;
  late final TextEditingController _emailController = TextEditingController()
    ..text = '';

  bool _isAutoExpired = false;

  TextStyle basicStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  Gradient gradient4 = LinearGradient(
    colors: [
      Colors.black.withOpacity(0.8),
      Colors.grey[500]!.withOpacity(0.8),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    // requestFCM();
  }

  // Lấy FCM token thật từ thiết bị thay vì giá trị giả
  Future<String?> getDeviceToken() async {
    try {
      print('===== FCM DEBUG: getDeviceToken() called from CreateUserFormScreen =====');
      
      // Kiểm tra xem Firebase Messaging có sẵn không
      if (Platform.isAndroid || Platform.isIOS) {
        // Kích hoạt quyền thông báo nếu cần
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        // Lấy token thật
        final token = await FirebaseMessaging.instance.getToken();
        print('===== FCM DEBUG: Received REAL FCM token: $token =====');
        return token;
      } else {
        print('===== FCM DEBUG: Platform not supported for FCM, using mock token =====');
        return "mock-token-${DateTime.now().millisecondsSinceEpoch}";
      }
    } catch (e) {
      print('===== FCM DEBUG: Error getting FCM token: $e =====');
      print('===== FCM DEBUG: Falling back to mock token =====');
      return "mock-token-on-error-${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Future<void> requestFCM() async {
  //   await FirebaseMessaging.instance.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
    
  //   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //     alert: false,
  //     badge: false,
  //     sound: false,
  //   );

  //   final token = await FirebaseMessaging.instance.getToken();
  //   debugPrint(token);
  //   FirebaseMessaging.onMessage.listen((event) {
  //     //have message on foreground => by pass notification
  //     debugPrint(event.data.toString());
  //   });
  // }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _userNameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                labelText: "User Name",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password),
                labelText: "Phone",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.cleaning_services),
                labelText: "Email",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAutoExpired = !_isAutoExpired;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isAutoExpired
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 24,
                      color: _isAutoExpired ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Auto Expired",
                      style: TextStyle(
                        fontSize: 16,
                        color: _isAutoExpired ? Colors.blue : Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                try {
                  print('\n===== Starting room creation process =====');
                  EasyLoading.show();
                  print('EasyLoading.show() called');
                  
                  // final fcm = await FirebaseMessaging.instance.getToken();
                  print('Requesting FCM token');
                  final fcm = await getDeviceToken();
                  print('FCM token received: $fcm');
                  
                  print('Creating room with:');
                  print('- Phone: ${_phoneController.text}');
                  print('- Name: ${_userNameController.text}');
                  print('- UUID: ${_phoneController.text}');
                  print('- AutoExpired: $_isAutoExpired');
                  print('- FCM: $fcm');
                  print('- ProjectId: omicrm-6558a');
                  
                  final result = await LiveTalkSdk.shareInstance.createRoom(
                    phone: _phoneController.text,
                    fullName: _userNameController.text,
                    uuid: _phoneController.text,
                    autoExpired: _isAutoExpired,
                    fcm: fcm,
                    projectId: "omicrm-6558a"
                  );
                  
                  print('Room creation result: $result');
                  EasyLoading.dismiss();
                  print('EasyLoading.dismiss() called');
                  
                  if (result != null && mounted) {
                    print('Navigating to ChatScreen');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          roomId: result,
                          uuid: _phoneController.text,
                        ),
                      ),
                    );
                    print('Navigation completed');
                  } else {
                    print('Result was null or widget not mounted - no navigation');
                  }
                } catch (error) {
                  print('Error creating room: $error');
                  EasyLoading.dismiss();
                  print('EasyLoading.dismiss() called after error');
                  
                  if (error is LiveTalkError) {
                    print('LiveTalkError: ${error.message["message"]}');
                    showCustomDialog(
                      context: context,
                      message: error.message["message"] as String,
                    );
                    print('Dialog shown');
                  } else {
                    print('Unknown error type: ${error.runtimeType}');
                  }
                }
                print('===== Room creation process completed =====\n');
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal,
                      Colors.teal[200]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

OutlineInputBorder myInputBorder() {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
    borderSide: BorderSide(
      color: Colors.redAccent,
      width: 3,
    ),
  );
}

OutlineInputBorder myFocusBorder() {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
    borderSide: BorderSide(
      color: Colors.greenAccent,
      width: 3,
    ),
  );
}
