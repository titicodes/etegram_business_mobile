import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/model/notification_model.dart';
import '../../../service/web/notification_api_service.dart';

class NotificationViewModel extends BaseViewModel {
  final NotificationService _notificationService = locator<NotificationService>();
  bool isPushNotificationEnabled = false;

  NotificationViewModel() {
    _loadInitialState();
  }

  void _loadInitialState() {
    final box = GetStorage();
    isPushNotificationEnabled = box.read('pushNotificationsEnabled') ?? false;
    notifyListeners();
  }

  Future<void> init() async {
    startLoader();
    try {
      await _notificationService.init();
      await fetchNotifications(); // Fetch initial notifications
      notifyListeners();
    } catch (e) {
      showCustomToast('Failed to initialize notifications: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationService.notificationsStream;

  ValueNotifier<int> get unreadCount => _notificationService.unreadCount;

  Future<void> fetchNotifications({int limit = 20, int skip = 0}) async {
    startLoader();
    try {
      await _notificationService.getNotifications(limit: limit, skip: skip);
      notifyListeners();
    } catch (e) {
      showCustomToast('Failed to fetch notifications: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    startLoader();
    try {
      await _notificationService.markAsRead(notificationId);
      notifyListeners();
    } catch (e) {
      showCustomToast('Failed to mark notification as read: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> togglePushNotification(bool value) async {
    startLoader();
    try {
      isPushNotificationEnabled = value;
      await _notificationService.togglePushNotification(value);
      final box = GetStorage();
      await box.write('pushNotificationsEnabled', value);
      print('NotificationViewModel: Push notifications ${value ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      showCustomToast('Failed to toggle push notifications: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  @override
  void dispose() {
    print('NotificationViewModel: Disposing');
    _notificationService.dispose();
    super.dispose();
  }
}