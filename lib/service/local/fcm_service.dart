import 'dart:convert';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

import '../../module/account/model/chat_message.dart';

class FcmService {
  final CustomerService _customerService;

  FcmService(this._customerService);

  Future<void> initialize() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await _customerService.updateFcmToken(token);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final box = GetStorage();
        final notification = ChatMessage(
          userId: _customerService.customer?.id,
          messageContent:
              '${message.notification!.title}: ${message.notification!.body}',
          messageType: 'receiver',
          createdAt: DateTime.now(),
        );
        final notifications = box.read('notifications') != null
            ? List<Map<String, dynamic>>.from(
                jsonDecode(box.read('notifications')))
            : [];
        notifications.add(notification.toJson());
        box.write('notifications', jsonEncode(notifications));
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    if (message.notification != null) {
      final box = GetStorage();
      final notification = ChatMessage(
        userId: null,
        messageContent:
            '${message.notification!.title}: ${message.notification!.body}',
        messageType: 'receiver',
        createdAt: DateTime.now(),
      );
      final notifications = box.read('notifications') != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(box.read('notifications')))
          : [];
      notifications.add(notification.toJson());
      box.write('notifications', jsonEncode(notifications));
    }
  }
}
