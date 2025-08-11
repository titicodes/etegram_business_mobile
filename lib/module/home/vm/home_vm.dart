import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/repository/auth_repository.dart';
import 'package:etegram_business/utils/image_utils.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/service/web/notification_api_service.dart';

class HomeViewModel extends BaseViewModel {
  GlobalKey<ScaffoldState>? scaffoldKey;
  Customer? customer;
  BuildContext? context;
  String name = '';
  String email = '';
  final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(null);
  final NotificationService _notificationService =
      locator<NotificationService>();
  bool _mounted = true;

  bool get mounted => _mounted;

  Stream<Customer?> getUserData() async* {
    final authResponse = await locator<AuthRepository>().getUser();
    yield authResponse?.data?.user;
  }

  Future<void> init() async {
    if (!_mounted) {
      print('HomeViewModel: init called but not mounted, aborting');
      return;
    }
    startLoader();
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      customer = authResponse?.data?.user ??
          await locator<AuthRepository>().getLocalServiceDetail();
      if (customer != null) {
        print(
            '✅ User fetched: ${customer!.firstName} ${customer!.lastName}, id: ${customer!.id}');
        await userService.storeUser(customer!);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;

        final userId = await userService.getOwnerId();
        final box = GetStorage();
        String? accessToken = box.read(DbTable.tokenTableName);
        if (accessToken == null) {
          throw "No authentication token found";
        }
        print('HomeViewModel: userId: $userId, accessToken: $accessToken');

        if (userId == null || accessToken == null) {
          print('⚠️ NotificationService: Missing user ID or access token');
          _safeShowToast(
              'Cannot initialize notifications: User not authenticated',
              success: false);
        } else {
          try {
            await _notificationService.init();
            print('✅ NotificationService initialized successfully');
          } catch (e) {
            print('❌ NotificationService: Error during initialization: $e');
            _safeShowToast('Failed to initialize notifications: $e',
                success: false);
          }
        }
      } else {
        print('⚠️ Failed to fetch user data from API & local storage');
        _safeShowToast('Failed to fetch user data', success: false);
      }
    } catch (err) {
      print('❌ Error during init: $err');
      _safeShowToast('Initialization failed: $err', success: false);
    } finally {
      if (_mounted) stopLoader();
    }
    if (_mounted) notifyListeners();
  }

  Future<void> refresh() async {
    if (!_mounted) {
      print('HomeViewModel: refresh called but not mounted, aborting');
      return;
    }
    startLoader();
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      final response = authResponse?.data?.user;
      if (response != null) {
        customer = response;
        await userService.storeUser(response);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;
        print(
            '✅ User data refreshed: ${customer!.firstName} ${customer!.lastName}');
      } else {
        print('⚠️ Failed to refresh user data from API');
        _safeShowToast('Failed to refresh user data', success: false);
      }
    } catch (err) {
      print('❌ Error during refresh: $err');
      _safeShowToast('Refresh failed: $err', success: false);
    } finally {
      if (_mounted) stopLoader();
    }
    if (_mounted) notifyListeners();
  }

  Future<void> getStoredServiceProviderDetails() async {
    if (!_mounted) {
      print(
          'HomeViewModel: getStoredServiceProviderDetails called but not mounted, aborting');
      return;
    }
    startLoader();
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      final response = authResponse?.data?.user;
      if (response != null) {
        customer = response;
        await userService.storeUser(response);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;
        print(
            '✅ Stored service provider details fetched: ${customer!.firstName} ${customer!.lastName}');
      } else {
        print('⚠️ Failed to get stored service provider details from API');
        _safeShowToast('Failed to fetch stored provider details',
            success: false);
      }
    } catch (err) {
      print('❌ Error fetching stored provider details: $err');
      _safeShowToast('Failed to fetch provider details: $err', success: false);
    } finally {
      if (_mounted) stopLoader();
    }
    if (_mounted) notifyListeners();
  }

  void updateFullName() {
    if (!_mounted) {
      print('HomeViewModel: updateFullName called but not mounted, aborting');
      return;
    }
    name = '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'.trim();
    if (_mounted) notifyListeners();
  }

  String getFullName() => name;

  Future<void> pickProfileImage(BuildContext context,
      {required ImageSource source}) async {
    if (!_mounted) {
      print('HomeViewModel: pickProfileImage called but not mounted, aborting');
      return;
    }
    startLoader(message: 'Processing image...');
    try {
      final (compressedFile, fileName) =
          await ImageUtils.pickAndCompressImage(context, source: source);
      if (compressedFile != null && fileName != null) {
        await _uploadProfileImage(compressedFile, fileName);
      } else {
        if (_mounted)
          _safeShowToast('Failed to process image or filename missing.',
              success: false);
      }
    } finally {
      if (_mounted) stopLoader();
    }
  }

  Future<void> _uploadProfileImage(File file, String fileName) async {
    if (!_mounted || customer?.id == null) {
      if (_mounted) _safeShowToast('User ID not found.', success: false);
      return;
    }

    startLoader(message: 'Uploading profile image...');
    try {
      final updatedCustomer =
          await locator<AuthRepository>().uploadProfileImage(
        customer!.id!,
        file.path,
        fileName: fileName,
      );

      if (updatedCustomer != null) {
        customer = updatedCustomer;
        await userService.storeUser(updatedCustomer);
        profileImageUrl.value = updatedCustomer.imageUrl;
        if (_mounted) {
          _safeShowToast('Profile image uploaded successfully!', success: true);
          notifyListeners();
        }
      } else {
        if (_mounted)
          _safeShowToast('Failed to upload profile image. Please try again.',
              success: false);
      }
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      if (_mounted)
        _safeShowToast('Error uploading profile image: $e', success: false);
    } finally {
      if (_mounted) stopLoader();
    }
  }

  Future<void> showImageSourceDialog(BuildContext context) async {
    if (!_mounted) {
      print(
          'HomeViewModel: showImageSourceDialog called but not mounted, aborting');
      return;
    }
    await ImageUtils.showImageSourceDialog(context, pickProfileImage);
  }

  void _safeShowToast(String message, {required bool success}) {
    if (!_mounted || context == null) {
      print(
          'HomeViewModel: Cannot show toast, not mounted or context is null: $message');
      return;
    }
    showCustomToast(message, success: success);
  }

  @override
  void dispose() {
    print('HomeViewModel: Disposing');
    _mounted = false;
    profileImageUrl.dispose();
    super.dispose();
  }
}
