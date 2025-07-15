// import 'dart:convert';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/core/model/auth_response.dart';
// import 'package:etegram_business/core/model/login_response.dart';
// import 'package:flutter/material.dart';
//
// class HomeViewModel extends BaseViewModel {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   late BuildContext context;
//
//   Customer? customer;
//   String name = '';
//   String email = "";
//
//   /// Opens the drawer
//   void openDrawer() {
//     scaffoldKey.currentState?.openDrawer();
//     notifyListeners();
//   }
//
//   /// Closes the drawer
//   void closeDrawer() {
//     scaffoldKey.currentState?.closeDrawer();
//     notifyListeners();
//   }
//
//   /// Fetches user data as a stream
//   Stream<Customer?> getUserData() async* {
//     yield await authRepository.getUser();
//   }
//
//   /// Initializes user data
//   Future<void> init() async {
//     try {
//       customer = await authRepository.getUser () ?? await authRepository.getLocalServiceDetail();
//
//       if (customer != null) {
//         print("✅ User fetched: ${customer!.firstName} ${customer!.lastName}");
//         userService.getStoreUser ();
//         updateFullName();
//       } else {
//         print("⚠️ Failed to fetch user data from API & local storage");
//       }
//     } catch (err) {
//       print("❌ Error during init: $err");
//     }
//
//     notifyListeners();
//   }
//
//   /// Refreshes user data
//   Future<void> refresh() async {
//     try {
//       Customer? response = await authRepository.getUser();
//       if (response != null) {
//         customer = response;
//         userService.storeUser(response);
//         updateFullName();
//       } else {
//         print("⚠️ Failed to refresh user data from API");
//       }
//     } catch (err) {
//       print("❌ Error during refresh: $err");
//     }
//     notifyListeners();
//   }
//
//   /// Gets stored service provider details
//   Future<void> getStoredServiceProviderDetails() async {
//     try {
//       Customer? response = await authRepository.getUser();
//       if (response != null) {
//         customer = response;
//         userService.storeUser(response);
//         updateFullName();
//       } else {
//         print("⚠️ Failed to get stored service provider details from API");
//       }
//     } catch (err) {
//       print("❌ Error fetching stored provider details: $err");
//     }
//     notifyListeners();
//   }
//
//   /// Updates the full name of the user
//   void updateFullName() {
//     name = "${customer?.firstName ?? ""} ${customer?.lastName ?? ""}".trim();
//     notifyListeners();
//   }
//
//   /// Returns the full name of the user
//   String getFullName() => name;
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../core/model/auth_response.dart';
import '../../../locator.dart';
import '../../../repository/auth_repository.dart';
import '../../../utils/image_utils.dart';
import '../../../utils/snack_message.dart';

class HomeViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late BuildContext context;
  Customer? customer;
  String name = '';
  String email = "";
  final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(null);

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
    notifyListeners();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
    notifyListeners();
  }

  Stream<Customer?> getUserData() async* {
    final authResponse = await locator<AuthRepository>().getUser();
    yield authResponse?.data?.user;
  }

  Future<void> init() async {
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      customer = authResponse?.data?.user ??
          await locator<AuthRepository>().getLocalServiceDetail();
      if (customer != null) {
        print("✅ User fetched: ${customer!.firstName} ${customer!.lastName}");
        await userService.storeUser(customer);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;
      } else {
        print("⚠️ Failed to fetch user data from API & local storage");
      }
    } catch (err) {
      print("❌ Error during init: $err");
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      final response = authResponse?.data?.user;
      if (response != null) {
        customer = response;
        await userService.storeUser(response);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;
      } else {
        print("⚠️ Failed to refresh user data from API");
      }
    } catch (err) {
      print("❌ Error during refresh: $err");
    }
    notifyListeners();
  }

  Future<void> getStoredServiceProviderDetails() async {
    try {
      final authResponse = await locator<AuthRepository>().getUser();
      final response = authResponse?.data?.user;
      if (response != null) {
        customer = response;
        await userService.storeUser(response);
        updateFullName();
        profileImageUrl.value = customer!.imageUrl;
      } else {
        print("⚠️ Failed to get stored service provider details from API");
      }
    } catch (err) {
      print("❌ Error fetching stored provider details: $err");
    }
    notifyListeners();
  }

  void updateFullName() {
    name = "${customer?.firstName ?? ""} ${customer?.lastName ?? ""}".trim();
    notifyListeners();
  }

  String getFullName() => name;

  Future<void> pickProfileImage(BuildContext context, {required ImageSource source}) async {
    startLoader(message: 'Processing image...');
    try {
      final (compressedFile, fileName) = await ImageUtils.pickAndCompressImage(context, source: source);
      if (compressedFile != null && fileName != null) {
        await _uploadProfileImage(compressedFile, fileName);
      } else {
        showCustomToast('Failed to process image or filename missing.', success: false);
      }
    } finally {
      stopLoader();
    }
  }

  Future<void> _uploadProfileImage(File file, String fileName) async {
    if (customer?.id == null) {
      showCustomToast('User ID not found.', success: false);
      return;
    }

    startLoader(message: 'Uploading profile image...');
    try {
      final updatedCustomer = await locator<AuthRepository>().uploadProfileImage(
        customer!.id!,
        file.path,
        fileName: fileName,
      );

      if (updatedCustomer != null) {
        customer = updatedCustomer;
        await userService.storeUser(updatedCustomer);
        profileImageUrl.value = updatedCustomer.imageUrl;
        showCustomToast('Profile image uploaded successfully!');
      } else {
        showCustomToast('Failed to upload profile image. Please try again.', success: false);
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      showCustomToast('Error uploading profile image: $e', success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> showImageSourceDialog(BuildContext context) async {
    await ImageUtils.showImageSourceDialog(context, pickProfileImage);
  }

  @override
  void dispose() {
    profileImageUrl.dispose();
    super.dispose();
  }
}
