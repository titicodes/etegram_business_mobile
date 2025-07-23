import 'dart:async';
import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/core/model/notification_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import '../../utils/snack_message.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = connect();
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final StreamController<List<NotificationModel>> _notificationsController =
  StreamController<List<NotificationModel>>.broadcast();
  bool _isPermissionRequested = false;
  bool _isInitialized = false;

  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsController.stream;

  Future<String?> _getToken() async {
    final box = GetStorage();
    String? token = box.read(DbTable.tokenTableName);
    if (token == null) {
      print('NotificationService: No authentication token found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(
          'No authentication token found',
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          position: ToastPosition.bottom,
          duration: const Duration(seconds: 3),
        );
      });
    }
    return token;
  }

  Future<void> init() async {
    if (_isInitialized) {
      print('NotificationService: Already initialized, skipping');
      return;
    }

    try {
      _isInitialized = true;

      if (!_isPermissionRequested) {
        _isPermissionRequested = true;
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('NotificationService: User granted permission');
        } else {
          print('NotificationService: User denied permission');
          _isPermissionRequested = false;
          return;
        }
      }

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final userId = await locator<CustomerService>().getOwnerId();
      final accessToken = await _getToken();
      if (userId == null || accessToken == null) {
        print('NotificationService: Missing userId or accessToken');
        throw Exception('Missing userId or accessToken');
      }

      final String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null) {
        print('NotificationService: Failed to get FCM token');
        throw Exception('Failed to get FCM token');
      }
      print('NotificationService: FCM Token: $fcmToken');

      try {
        await locator<CustomerService>().updateFcmToken(fcmToken);
        print('NotificationService: FCM token updated successfully');
      } catch (e) {
        print('NotificationService: Failed to update FCM token: $e');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('NotificationService: Foreground message received: ${message.data}');
        _updateUnreadCount();
        if (message.notification != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast(
              message.notification!.body ?? 'New notification',
              backgroundColor: Colors.blue,
              textStyle: const TextStyle(color: Colors.white),
              position: ToastPosition.bottom,
              duration: const Duration(seconds: 3),
            );
          });
        }
        getNotifications();
      });

      await _updateUnreadCount();
      await getNotifications();
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('NotificationService: Initialization error: $e');
      throw e;
    } finally {
      _isPermissionRequested = false;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('NotificationService: Background message received: ${message.data}');
    await GetStorage.init();
    final dio = Dio(BaseOptions(baseUrl: AppUrls.baseUrl));
    final box = GetStorage();

    try {
      final accessToken = box.read(DbTable.tokenTableName);
      if (accessToken == null) {
        print('NotificationService: No access token in background handler');
        return;
      }

      final response = await dio.get(
        'notifications/unread-count',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        print('NotificationService: Unread count updated in background: ${response.data['unreadCount']}');
      } else {
        print('NotificationService: Failed to fetch unread count in background, status: ${response.statusCode}');
      }
    } catch (e) {
      print('NotificationService: Error in background handler: $e');
    }
  }

  Future<void> _updateUnreadCount() async {
    if (_notificationsController.isClosed) {
      print('NotificationService: StreamController is closed, skipping unread count update');
      return;
    }

    try {
      final userId = await locator<CustomerService>().getOwnerId();
      final accessToken = await _getToken();
      if (userId == null || accessToken == null) {
        print('NotificationService: No userId or accessToken for unread count');
        return;
      }

      final response = await _dio.get(
        'notifications/unread-count',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        unreadCount.value = response.data['unreadCount'] ?? 0;
        print('NotificationService: Unread count updated: ${unreadCount.value}');
      } else {
        print('NotificationService: Failed to fetch unread count, status: ${response.statusCode}');
      }
    } catch (e) {
      print('NotificationService: Error updating unread count: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications({int limit = 20, int skip = 0}) async {
    if (_notificationsController.isClosed) {
      print('NotificationService: StreamController is closed, cannot fetch notifications');
      throw Exception('StreamController is closed');
    }

    try {
      final userId = await locator<CustomerService>().getOwnerId();
      final accessToken = await _getToken();
      if (userId == null || accessToken == null) {
        print('NotificationService: No userId or accessToken for fetching notifications');
        throw Exception('No userId or accessToken');
      }

      final response = await _dio.get(
        '${AppUrls.baseUrl}notifications?limit=$limit&skip=$skip',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic>? data = response.data['notifications'];
        final notifications = data?.map((json) => NotificationModel.fromJson(json)).toList() ?? [];
        _notificationsController.add(notifications);
        print('NotificationService: Fetched ${notifications.length} notifications');
        return notifications;
      } else {
        print('NotificationService: Failed to fetch notifications, status: ${response.statusCode}');
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('NotificationService: Error fetching notifications: $e');
      throw e;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_notificationsController.isClosed) {
      print('NotificationService: StreamController is closed, cannot mark notification as read');
      return;
    }

    try {
      final userId = await locator<CustomerService>().getOwnerId();
      final accessToken = await _getToken();
      if (userId == null || accessToken == null) {
        print('NotificationService: No userId or accessToken for marking notification as read');
        throw Exception('No userId or accessToken');
      }

      final response = await _dio.patch(
        '${AppUrls.baseUrl}notifications/$notificationId/read',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        print('NotificationService: Notification $notificationId marked as read');
        await _updateUnreadCount();
        await getNotifications();
      } else {
        print('NotificationService: Failed to mark notification as read, status: ${response.statusCode}');
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('NotificationService: Error marking notification as read: $e');
      throw e;
    }
  }

  Future<void> togglePushNotification(bool enable) async {
    try {
      if (enable) {
        await _firebaseMessaging.subscribeToTopic('store_owners');
        print('NotificationService: Subscribed to store_owners topic');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('store_owners');
        print('NotificationService: Unsubscribed from store_owners topic');
      }
    } catch (e) {
      print('NotificationService: Error toggling push notification: $e');
      throw e;
    }
  }

  void dispose() {
    print('NotificationService: Disposing');
    if (!_notificationsController.isClosed) {
      _notificationsController.close();
    }
  }
}