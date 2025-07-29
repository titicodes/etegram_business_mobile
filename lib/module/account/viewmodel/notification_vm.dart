// import 'package:dio/dio.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:rxdart/rxdart.dart';
//
// import '../../../core/model/notification_model.dart';
// import '../../../service/web/notification_api_service.dart';
//
// class NotificationViewModel extends BaseViewModel {
//   final NotificationService _notificationService = locator<NotificationService>();
//   bool isPushNotificationEnabled = false;
//   bool _isFetching = false;
//
//   NotificationViewModel() {
//     _loadInitialState();
//   }
//
//   void _loadInitialState() {
//     final box = GetStorage();
//     isPushNotificationEnabled = box.read('pushNotificationsEnabled') ?? false;
//     notifyListeners();
//   }
//
//   Future<void> init() async {
//     startLoader();
//     try {
//       await _notificationService.init();
//       await fetchNotifications();
//       notifyListeners();
//     } catch (e) {
//       if (e is DioException && e.type == DioExceptionType.cancel) {
//         print('NotificationViewModel: Initialization canceled');
//         return;
//       }
//       showCustomToast('Failed to initialize notifications: $e', success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Stream<List<NotificationModel>> get notificationsStream =>
//       _notificationService.notificationsStream;
//
//   ValueNotifier<int> get unreadCount => _notificationService.unreadCount;
//
//   Future<void> fetchNotifications({int limit = 20, int skip = 0}) async {
//     if (_isFetching) {
//       print('NotificationViewModel: Skipping fetch, already in progress');
//       return;
//     }
//
//     _isFetching = true;
//     startLoader();
//     try {
//       await _notificationService.getNotifications(limit: limit, skip: skip);
//       notifyListeners();
//     } catch (e) {
//       if (e is DioException && e.type == DioExceptionType.cancel) {
//         print('NotificationViewModel: Fetch notifications canceled');
//         return;
//       }
//       showCustomToast('Failed to fetch notifications: $e', success: false);
//     } finally {
//       _isFetching = false;
//       stopLoader();
//     }
//   }
//
//   Future<void> markNotificationAsRead(String notificationId) async {
//     startLoader();
//     try {
//       await _notificationService.markAsRead(notificationId);
//       notifyListeners();
//     } catch (e) {
//       if (e is DioException && e.type == DioExceptionType.cancel) {
//         print('NotificationViewModel: Mark notification as read canceled');
//         return;
//       }
//       showCustomToast('Failed to mark notification as read: $e', success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Future<void> togglePushNotification(bool value) async {
//     startLoader();
//     try {
//       isPushNotificationEnabled = value;
//       await _notificationService.togglePushNotification(value);
//       final box = GetStorage();
//       await box.write('pushNotificationsEnabled', value);
//       print('NotificationViewModel: Push notifications ${value ? 'enabled' : 'disabled'}');
//       notifyListeners();
//     } catch (e) {
//       if (e is DioException && e.type == DioExceptionType.cancel) {
//         print('NotificationViewModel: Toggle push notification canceled');
//         return;
//       }
//       showCustomToast('Failed to toggle push notifications: $e', success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   @override
//   void dispose() {
//     print('NotificationViewModel: Disposing');
//     _notificationService.dispose();
//     super.dispose();
//   }
// }

import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/model/notification_model.dart';
import '../../../service/web/notification_api_service.dart';

class NotificationViewModel extends BaseViewModel {
  final NotificationService _notificationService =
      locator<NotificationService>();
  bool isPushNotificationEnabled = false;
  bool isFetching = false;
  bool isTapping = false;
  int _skip = 0;
  final int _limit = 10;
  final List<NotificationModel> _allNotifications = [];

  NotificationViewModel() {
    _loadInitialState();
  }

  void _loadInitialState() {
    final box = GetStorage();
    isPushNotificationEnabled = box.read('pushNotificationsEnabled') ?? false;
    notifyListeners();
  }

  void setTapping(bool value) {
    isTapping = value;
    notifyListeners();
  }

  Future<void> init() async {
    startLoader();
    try {
      await _notificationService.init();
      await fetchNotifications();
      notifyListeners();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('NotificationViewModel: Initialization canceled');
        return;
      }
      showCustomToast('Failed to initialize notifications: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationService.notificationsStream;

  ValueNotifier<int> get unreadCount => _notificationService.unreadCount;

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (isFetching) {
      print('NotificationViewModel: Skipping fetch, already in progress');
      return;
    }

    isFetching = true;
    startLoader();
    try {
      if (!loadMore) {
        _skip = 0;
        _allNotifications.clear();
      }
      final notifications = await _notificationService.getNotifications(
        limit: _limit,
        skip: _skip,
      );
      _allNotifications.addAll(notifications);
      _skip += notifications.length;
      _notificationService.updateNotifications(_allNotifications);
      notifyListeners();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('NotificationViewModel: Fetch notifications canceled');
        return;
      }
      showCustomToast('Failed to fetch notifications: $e', success: false);
    } finally {
      isFetching = false;
      stopLoader();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    startLoader();
    try {
      await _notificationService.markAsRead(notificationId);
      notifyListeners();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('NotificationViewModel: Mark notification as read canceled');
        return;
      }
      showCustomToast('Failed to mark notification as read: $e',
          success: false);
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
      print(
          'NotificationViewModel: Push notifications ${value ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('NotificationViewModel: Toggle push notification canceled');
        return;
      }
      showCustomToast('Failed to toggle push notifications: $e',
          success: false);
    } finally {
      stopLoader();
    }
  }

  @override
  void dispose() {
    print('NotificationViewModel: Disposing');
    // Do not dispose _notificationService since it's a singleton
    super.dispose();
  }
}
