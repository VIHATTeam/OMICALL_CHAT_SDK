import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:livetalk_sdk_example/create_user_form_screen.dart';

import 'notification_service.dart';

// Hàm xử lý tin nhắn Firebase khi ứng dụng ở chế độ nền
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  print("===== FCM DEBUG: Handling a background message: ${message.messageId} =====");
  print("===== FCM DEBUG: Background message data: ${message.data} =====");
}

void main() async {
  print('\n\n======= APPLICATION STARTING (main_with_firebase.dart) =======\n\n');
  
  // Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  print('Flutter binding initialized');
  
  // Cấu hình HTTP để bỏ qua lỗi chứng chỉ không hợp lệ
  HttpOverrides.global = MyHttpOverrides();
  print('Custom HTTP overrides applied');
  
  // Khởi tạo SDK của LiveTalk với tên miền quidn
  print('Initializing LiveTalkSDK with domain: quidn');
  LiveTalkSdk(domainPbx: "quidn");
  
  // Khởi tạo Firebase
  print('Initializing Firebase...');
  
  // Tắt chế độ tự động thu thập dữ liệu phân tích (tuỳ chọn)
  // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  
  await Firebase.initializeApp(
    // Các tùy chọn khởi tạo có thể được thêm ở đây nếu cần
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized successfully');
  
  // Khởi tạo dịch vụ thông báo
  print('Initializing NotificationService');
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Đăng ký handler xử lý tin nhắn background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('Background message handler registered');

  // Khởi động ứng dụng
  print('Running application');
  runApp(const MyApp());
  print('\n\n======= APPLICATION STARTED =======\n\n');
}

// Lớp cấu hình Firebase mặc định (bạn cần tạo lớp này hoặc sử dụng lớp từ firebase_options.dart)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS) {
      return const FirebaseOptions(
        apiKey: 'YOUR_IOS_API_KEY',
        appId: 'YOUR_IOS_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
      );
    } else if (Platform.isAndroid) {
      return const FirebaseOptions(
        apiKey: 'YOUR_ANDROID_API_KEY',
        appId: 'YOUR_ANDROID_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
      );
    }
    
    throw UnsupportedError('Unsupported platform');
  }
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
    
    // Cấu hình EasyLoading
    EasyLoading.instance.userInteractions = false;

    // Đăng ký lắng nghe sự kiện tin nhắn FCM khi ứng dụng mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('===== FCM DEBUG: Foreground message received =====');
      // Sử dụng dịch vụ thông báo để xử lý thông báo
      NotificationService().showNotification(message);
    });

    // Đăng ký lắng nghe sự kiện khi người dùng nhấp vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('===== FCM DEBUG: Message clicked! =====');
      print('===== FCM DEBUG: Message data: ${message.data} =====');
      // Thêm logic xử lý khi người dùng nhấp vào thông báo ở đây
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building MyApp widget');
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

// Bỏ qua lỗi chứng chỉ SSL không hợp lệ
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
          ) {
        // Lưu ý: Cấu hình này không an toàn cho môi trường sản xuất
        return true;
      };
  }
}
