// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:etegram_business/core/model/subscription_model.dart';
// import 'package:etegram_business/constants/app_url.dart';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:etegram_business/locator.dart';
// import '../../../constants/reuseable.dart';
// import '../../../service/local/user_service.dart';
// import '../../../service/web/base_api.dart';
// import '../../account/model/chat_message.dart';
//
// class ProfileViewModel extends BaseViewModel {
//   final CustomerService _customerService = locator<CustomerService>();
//   bool isEmailSelected = false;
//   bool isPushNotificationSelected = false;
//   String? errorMessage;
//   String messageContent = ''; // Store message input
//
//   // Profile editing fields
//   bool isEdit = false;
//   var firstNameController = TextEditingController();
//   var lastNameController = TextEditingController();
//   var userNameController = TextEditingController();
//   var emailNameController = TextEditingController();
//   String? selectedImage;
//   File? selectedImageFile;
//   bool showEdit = false;
//
//   ProfileViewModel() {
//     _loadInitialState();
//   }
//
//   void _loadInitialState() {
//     final box = GetStorage();
//     isPushNotificationSelected = box.read('pushNotificationsEnabled') ?? false;
//     isEmailSelected = box.read('emailNotificationsEnabled') ?? false;
//     // Initialize profile fields
//     firstNameController.text = _customerService.customer?.firstName ?? '';
//     lastNameController.text = _customerService.customer?.lastName ?? '';
//     userNameController.text = _customerService.customer?.firstName ?? '';
//     emailNameController.text = _customerService.customer?.email ?? '';
//     notifyListeners();
//   }
//
//   void toggleEmailSwitch(bool value) {
//     isEmailSelected = value;
//     GetStorage().write('emailNotificationsEnabled', value);
//     notifyListeners();
//   }
//
//   void togglePushedNotificationSwitch(bool value) {
//     isPushNotificationSelected = value;
//     GetStorage().write('pushNotificationsEnabled', value);
//     notifyListeners();
//   }
//
//   Future<void> fetchSubscriptionStatus() async {
//     try {
//       startLoader();
//       await _customerService.fetchSubscriptionStatus();
//       errorMessage = null;
//     } catch (e) {
//       errorMessage = 'Failed to fetch subscription status';
//       showCustomToast(errorMessage!, success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Future<void> subscribeToPremium(String type) async {
//     try {
//       startLoader();
//       await _customerService.subscribeToPremium(type);
//       errorMessage = null;
//     } catch (e) {
//       errorMessage = 'Failed to subscribe to premium';
//       showCustomToast(errorMessage!, success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   Future<void> cancelSubscription() async {
//     try {
//       startLoader();
//       await _customerService.cancelSubscription();
//       errorMessage = null;
//     } catch (e) {
//       errorMessage = 'Failed to cancel subscription';
//       showCustomToast(errorMessage!, success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   bool isPremiumFeatureAccessible() {
//     // During internal testing, allow access to all features
//     print(
//         "ProfileViewModel: Allowing premium feature access for internal testing");
//     return true;
//   }
//
//   Future<List<ChatMessage>> getMessages() async {
//     final box = GetStorage();
//     try {
//       String? accessToken = box.read(DbTable.tokenTableName);
//       String? userId = _customerService.customer?.id;
//       if (accessToken == null || userId == null) {
//         print("getMessages: No access token or user ID");
//         final storedJson = box.read('notifications');
//         if (storedJson == null) return [];
//         final decoded = jsonDecode(storedJson);
//         return decoded is List
//             ? decoded.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList()
//             : [];
//       }
//       final response = await connect().get(
//         '${AppUrls.baseUrl}messages',
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//       print(
//           "getMessages: Response status: ${response.statusCode}, data: ${response.data}");
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData['data'] is List) {
//           final messages = (responseData['data'] as List)
//               .map((json) => ChatMessage.fromJson(json))
//               .toList()
//             ..sort((a, b) => (a.createdAt ?? DateTime(0))
//                 .compareTo(b.createdAt ?? DateTime(0)));
//           await box.write('notifications',
//               jsonEncode(messages.map((m) => m.toJson()).toList()));
//           errorMessage = null;
//           return messages;
//         } else {
//           print("getMessages: Unexpected response format: $responseData");
//           errorMessage = 'Unexpected response format';
//           return [];
//         }
//       }
//       errorMessage = 'Failed to fetch messages: ${response.statusCode}';
//       showCustomToast(errorMessage!, success: false);
//       return [];
//     } catch (e) {
//       print("Error fetching messages: $e");
//       errorMessage = 'Failed to fetch messages: $e';
//       showCustomToast(errorMessage!, success: false);
//       final storedJson = box.read('notifications');
//       if (storedJson == null) return [];
//       final decoded = jsonDecode(storedJson);
//       return decoded is List
//           ? decoded.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList()
//           : [];
//     }
//   }
//
//   Future<void> sendMessage(String content) async {
//     try {
//       startLoader();
//       final box = GetStorage();
//       String? accessToken = box.read(DbTable.tokenTableName);
//       String? userId = _customerService.customer?.id;
//       if (accessToken == null || userId == null) {
//         errorMessage = 'Please log in to send messages';
//         showCustomToast(errorMessage!, success: false);
//         return;
//       }
//       final response = await connect().post(
//         '${AppUrls.baseUrl}messages',
//         data: {'content': content, 'type': 'sender', 'userId': userId},
//         options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
//       );
//       print(
//           "sendMessage: Response status: ${response.statusCode}, data: ${response.data}");
//       if (response.statusCode == 200) {
//         final message = ChatMessage.fromJson(response.data);
//         final notifications = box.read('notifications') != null
//             ? List<Map<String, dynamic>>.from(
//                 jsonDecode(box.read('notifications')))
//             : [];
//         notifications.add(message.toJson());
//         await box.write('notifications', jsonEncode(notifications));
//         errorMessage = null;
//         showCustomToast('Message sent successfully', success: true);
//         messageContent = '';
//         notifyListeners();
//       } else {
//         errorMessage = 'Failed to send message: ${response.statusCode}';
//         showCustomToast(errorMessage!, success: false);
//       }
//     } catch (e) {
//       print("Error sending message: $e");
//       errorMessage = 'Failed to send message: $e';
//       showCustomToast(errorMessage!, success: false);
//     } finally {
//       stopLoader();
//     }
//   }
//
//   void pickImage() {
//     showEdit = !showEdit;
//     notifyListeners();
//   }
//
//   Future<void> selectImage({ImageSource source = ImageSource.camera}) async {
//     pickImage();
//     final ImagePicker picker = ImagePicker();
//     final image = await picker.pickImage(source: source);
//     if (image == null) {
//       selectedImage = null;
//       selectedImageFile = null;
//     } else {
//       var files = File(image.path);
//       selectedImageFile = files;
//       selectedImage = image.path;
//     }
//     notifyListeners();
//   }
//
//   void changeEdit() {
//     isEdit = !isEdit;
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/subscription_model.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:etegram_business/locator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/reuseable.dart';
import '../../../repository/auth_repository.dart';
import '../../../service/local/user_service.dart';
import '../../../service/web/base_api.dart';
import '../../account/model/chat_message.dart';
import '../../../utils/image_utils.dart';

class ProfileViewModel extends BaseViewModel {
  final CustomerService _customerService = locator<CustomerService>();
  bool isEmailSelected = false;
  bool isPushNotificationSelected = false;
  String? errorMessage;
  String messageContent = '';
  final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(null);

  bool isEdit = false;
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var userNameController = TextEditingController();
  var emailNameController = TextEditingController();

  ProfileViewModel() {
    _loadInitialState();
  }

  void _loadInitialState() {
    final box = GetStorage();
    isPushNotificationSelected = box.read('pushNotificationsEnabled') ?? false;
    isEmailSelected = box.read('emailNotificationsEnabled') ?? false;
    firstNameController.text = _customerService.customer?.firstName ?? '';
    lastNameController.text = _customerService.customer?.lastName ?? '';
    userNameController.text = _customerService.customer?.firstName ?? '';
    emailNameController.text = _customerService.customer?.email ?? '';
    profileImageUrl.value = _customerService.customer?.imageUrl;
    notifyListeners();
  }

  loadInitialState() => _loadInitialState();

  void toggleEmailSwitch(bool value) {
    isEmailSelected = value;
    GetStorage().write('emailNotificationsEnabled', value);
    notifyListeners();
  }

  void togglePushedNotificationSwitch(bool value) {
    isPushNotificationSelected = value;
    GetStorage().write('pushNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      startLoader();
      await _customerService.fetchSubscriptionStatus();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to fetch subscription status';
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> subscribeToPremium(String type) async {
    try {
      startLoader();
      await _customerService.subscribeToPremium(type);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to subscribe to premium';
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> cancelSubscription() async {
    try {
      startLoader();
      await _customerService.cancelSubscription();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to cancel subscription';
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  bool isPremiumFeatureAccessible() {
    print("ProfileViewModel: Allowing premium feature access for internal testing");
    return true;
  }

  Future<List<ChatMessage>> getMessages() async {
    final box = GetStorage();
    try {
      String? accessToken = box.read(DbTable.tokenTableName);
      String? userId = _customerService.customer?.id;
      if (accessToken == null || userId == null) {
        print("getMessages: No access token or user ID");
        final storedJson = box.read('notifications');
        if (storedJson == null) return [];
        final decoded = jsonDecode(storedJson);
        return decoded is List
            ? decoded.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList()
            : [];
      }
      final response = await connect().get(
        '${AppUrls.baseUrl}/messages',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("getMessages: Response status: ${response.statusCode}, data: ${response.data}");
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] is List) {
          final messages = (responseData['data'] as List)
              .map((json) => ChatMessage.fromJson(json))
              .toList()
            ..sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
          await box.write('notifications', jsonEncode(messages.map((m) => m.toJson()).toList()));
          errorMessage = null;
          return messages;
        } else {
          print("getMessages: Unexpected response format: $responseData");
          errorMessage = 'Unexpected response format';
          return [];
        }
      }
      errorMessage = 'Failed to fetch messages: ${response.statusCode}';
      showCustomToast(errorMessage!, success: false);
      return [];
    } catch (e) {
      print("Error fetching messages: $e");
      errorMessage = 'Failed to fetch messages: $e';
      showCustomToast(errorMessage!, success: false);
      final storedJson = box.read('notifications');
      if (storedJson == null) return [];
      final decoded = jsonDecode(storedJson);
      return decoded is List
          ? decoded.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList()
          : [];
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      startLoader();
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      String? userId = _customerService.customer?.id;
      if (accessToken == null || userId == null) {
        errorMessage = 'Please log in to send messages';
        showCustomToast(errorMessage!, success: false);
        return;
      }
      final response = await connect().post(
        '${AppUrls.baseUrl}/messages',
        data: {'content': content, 'type': 'sender', 'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("sendMessage: Response status: ${response.statusCode}, data: ${response.data}");
      if (response.statusCode == 200) {
        final message = ChatMessage.fromJson(response.data);
        final notifications = box.read('notifications') != null
            ? List<Map<String, dynamic>>.from(jsonDecode(box.read('notifications')))
            : [];
        notifications.add(message.toJson());
        await box.write('notifications', jsonEncode(notifications));
        errorMessage = null;
        showCustomToast('Message sent successfully', success: true);
        messageContent = '';
        notifyListeners();
      } else {
        errorMessage = 'Failed to send message: ${response.statusCode}';
        showCustomToast(errorMessage!, success: false);
      }
    } catch (e) {
      print("Error sending message: $e");
      errorMessage = 'Failed to send message: $e';
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> pickProfileImage(BuildContext context, {required ImageSource source}) async {
    startLoader(message: 'Processing image...');
    try {
      final (compressedFile, fileName) = await ImageUtils.pickAndCompressImage(context, source: source);
      if (compressedFile != null && fileName != null) {
        await _uploadProfileImage(compressedFile, fileName);
      }
    } finally {
      stopLoader();
    }
  }

  Future<void> _uploadProfileImage(File file, String fileName) async {
    if (_customerService.customer?.id == null) {
      showCustomToast('User ID not found.', success: false);
      return;
    }

    startLoader(message: 'Uploading profile image...');
    try {
      final updatedCustomer = await locator<AuthRepository>().uploadProfileImage(
        _customerService.customer!.id!,
        file.path,
        fileName: fileName,
      );

      if (updatedCustomer != null) {
        await _customerService.storeUser(updatedCustomer);
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
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailNameController.dispose();
    profileImageUrl.dispose();
    super.dispose();
  }
}
