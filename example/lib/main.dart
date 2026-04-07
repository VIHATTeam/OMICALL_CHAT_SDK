import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:livetalk_sdk_example/create_user_form_screen.dart';

import 'notification_service.dart';

/// Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  LiveTalkSdk(domainPbx: "");

  // Initialize Firebase with error handling
  // Note: Requires GoogleService-Info.plist (iOS) and google-services.json (Android)
  try {
    // Initialize with default options (from config files)
    await Firebase.initializeApp(
      // On newer Firebase SDK, options are auto-detected from config files
      // If this fails, run: flutterfire configure
    );

    await NotificationService().init();

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print('===== Firebase initialized successfully =====');
  } catch (e) {
    print('===== Firebase initialization error: $e =====');
    print('===== Continuing without Firebase. Run "flutterfire configure" to fix. =====');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    EasyLoading.instance.userInteractions = false;

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService().showNotification(message);
    });

    // Listen for when user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
        theme: ThemeData.light(),
        home: const CreateUserFormScreen(),
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
      ),
      onTap: () {
        if (FocusManager.instance.primaryFocus?.hasFocus == true) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
          ) {
        return true;
      };
  }
}
