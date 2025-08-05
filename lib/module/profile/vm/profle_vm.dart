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
import '../../../service/web/notification_api_service.dart';

class ProfileViewModel extends BaseViewModel {
  final CustomerService _customerService = locator<CustomerService>();
  final NotificationService _notificationService = locator<NotificationService>();
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
    _init();
  }

  Future<void> _init() async {
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

  Future<void> init() async {
    startLoader();
    try {
      await _customerService.getStoreUser();
      await _init();
    } catch (e) {
      errorMessage = 'Failed to initialize profile: $e';
      print('ProfileViewModel: $errorMessage');
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  void toggleEmailSwitch(bool value) {
    isEmailSelected = value;
    GetStorage().write('emailNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> togglePushNotification(bool value) async {
    try {
      await _notificationService.togglePushNotification(value);
      isPushNotificationSelected = value;
      GetStorage().write('pushNotificationsEnabled', value);
      print('ProfileViewModel: Push notifications ${value ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to toggle push notifications: $e';
      print('ProfileViewModel: $errorMessage');
      showCustomToast(errorMessage!, success: false);
    }
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
        print("ProfileViewModel: No access token or user ID");
        final storedJson = box.read('chat_messages');
        if (storedJson == null) return [];
        final decoded = jsonDecode(storedJson);
        return decoded is List
            ? decoded.map<ChatMessage>((e) => ChatMessage.fromJson(e)).toList()
            : [];
      }
      final response = await connect().get(
        'messages',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("ProfileViewModel: getMessages Response status: ${response.statusCode}, data: ${response.data}");
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] is List) {
          final messages = (responseData['data'] as List)
              .map((json) => ChatMessage.fromJson(json))
              .toList()
            ..sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
          await box.write('chat_messages', jsonEncode(messages.map((m) => m.toJson()).toList()));
          errorMessage = null;
          return messages;
        } else {
          print("ProfileViewModel: Unexpected response format: $responseData");
          errorMessage = 'Unexpected response format';
          return [];
        }
      }
      errorMessage = 'Failed to fetch messages: ${response.statusCode}';
      showCustomToast(errorMessage!, success: false);
      return [];
    } catch (e) {
      print("ProfileViewModel: Error fetching messages: $e");
      errorMessage = 'Failed to fetch messages: $e';
      showCustomToast(errorMessage!, success: false);
      final storedJson = box.read('chat_messages');
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
        'messages',
        data: {'content': content, 'type': 'sender', 'userId': userId}, // Updated keys
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("ProfileViewModel: sendMessage Response status: ${response.statusCode}, data: ${response.data}");
      if (response.statusCode == 201) {
        final message = ChatMessage.fromJson(response.data['data']);
        final messages = box.read('chat_messages') != null
            ? List<Map<String, dynamic>>.from(jsonDecode(box.read('chat_messages')))
            : [];
        messages.add(message.toJson());
        await box.write('chat_messages', jsonEncode(messages));
        errorMessage = null;
        showCustomToast('Message sent successfully', success: true);
        messageContent = '';
        notifyListeners();
      } else {
        errorMessage = 'Failed to send message: ${response.statusCode}';
        showCustomToast(errorMessage!, success: false);
      }
    } catch (e) {
      print("ProfileViewModel: Error sending message: $e");
      errorMessage = 'Failed to send message: $e';
      showCustomToast(errorMessage!, success: false);
    } finally {
      stopLoader();
    }
  }

  Future<void> clearChatHistory() async {
    try {
      startLoader();
      final box = GetStorage();
      String? accessToken = box.read(DbTable.tokenTableName);
      String? userId = _customerService.customer?.id;
      if (accessToken == null || userId == null) {
        errorMessage = 'Please log in to clear chat history';
        showCustomToast(errorMessage!, success: false);
        return;
      }
      final response = await connect().delete(
        'chat/messages',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      print("ProfileViewModel: clearChatHistory Response status: ${response.statusCode}, data: ${response.data}");
      if (response.statusCode == 200) {
        await box.remove('chat_messages');
        errorMessage = null;
        showCustomToast('Chat history cleared successfully', success: true);
        notifyListeners();
      } else {
        errorMessage = 'Failed to clear chat history: ${response.statusCode}';
        showCustomToast(errorMessage!, success: false);
      }
    } catch (e) {
      print("ProfileViewModel: Error clearing chat history: $e");
      errorMessage = 'Failed to clear chat history: $e';
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
        notifyListeners();
      } else {
        showCustomToast('Failed to upload profile image. Please try again.', success: false);
      }
    } catch (e) {
      print("ProfileViewModel: Error uploading profile image: $e");
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