// This is a stub notification service for development
// Replace the Firebase implementation for testing purposes

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    print('===== FCM DEBUG: Initializing notification service =====');
    
    try {
      // Yêu cầu quyền thông báo cho iOS và Android
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true, 
          sound: true,
          announcement: false,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
        );
        
        print('===== FCM DEBUG: iOS notification permission status: ${settings.authorizationStatus} =====');
        
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        print('===== FCM DEBUG: iOS foreground notification options set =====');
      }
      
      // Android 13+ yêu cầu quyền rõ ràng
      if (Platform.isAndroid) {
        final settings = await FirebaseMessaging.instance.requestPermission();
        print('===== FCM DEBUG: Android notification permission status: ${settings.authorizationStatus} =====');
      }
      
      // Đăng ký token với server
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('===== FCM DEBUG: FCM Token: $fcmToken =====');
      
      // Đăng ký listeners để in logs và xử lý token mới
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('===== FCM DEBUG: FCM Token refreshed: $newToken =====');
        // Tại đây bạn có thể gửi token mới đến server của bạn
      });
      
      // Đăng ký xử lý thông báo khi ứng dụng đang mở
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });
      
      print('===== FCM DEBUG: Notification service initialized successfully =====');
    } catch (e) {
      print('===== FCM DEBUG: Error initializing FCM: $e =====');
    }
  }

  Future<void> showNotification(dynamic message) async {
    print('===== FCM DEBUG: Showing notification =====');
    
    try {
      if (message is RemoteMessage) {
        print('===== FCM DEBUG: RemoteMessage received: ${message.messageId} =====');
        print('===== FCM DEBUG: Notification: ${message.notification?.title}, ${message.notification?.body} =====');
        print('===== FCM DEBUG: Data: ${message.data} =====');
        
        // Xử lý tin nhắn dựa trên loại
        if (message.notification != null) {
          print('===== FCM DEBUG: Processing notification message =====');
          // FCM sẽ tự hiển thị thông báo này trên thiết bị
          // Nhưng bạn có thể thêm logic xử lý đặc biệt ở đây nếu cần
        }
        
        if (message.data.isNotEmpty) {
          print('===== FCM DEBUG: Processing data message =====');
          // Xử lý dữ liệu payload riêng
          // Đây là nơi bạn có thể thêm logic xử lý tùy chỉnh cho dữ liệu
        }
      } else {
        // Xử lý message không phải là RemoteMessage (cho mục đích testing)
        print('===== FCM DEBUG: Non-RemoteMessage object: $message =====');
        String messageText = "";
        
        if (message is Map) {
          messageText = message.toString();
        } else if (message is String) {
          messageText = message;
        } else {
          messageText = message.toString();
        }
        
        print('===== FCM DEBUG: Message content: $messageText =====');
      }
      
      print('===== FCM DEBUG: Notification processed =====');
    } catch (e) {
      print('===== FCM DEBUG: Error processing notification: $e =====');
    }
  }
  
  // Lấy FCM token hiện tại
  Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('===== FCM DEBUG: FCM token retrieved: $token =====');
      return token;
    } catch (e) {
      print('===== FCM DEBUG: Error getting FCM token: $e =====');
      return null;
    }
  }
  
  // Ghi danh nhận thông báo từ một topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('===== FCM DEBUG: Subscribed to topic: $topic =====');
    } catch (e) {
      print('===== FCM DEBUG: Error subscribing to topic: $e =====');
    }
  }
  
  // Hủy ghi danh nhận thông báo từ một topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('===== FCM DEBUG: Unsubscribed from topic: $topic =====');
    } catch (e) {
      print('===== FCM DEBUG: Error unsubscribing from topic: $e =====');
    }
  }
}