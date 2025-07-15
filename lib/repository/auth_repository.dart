import 'dart:convert';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/reuseable.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/web/auth_api.dart';
import '../utils/snack_message.dart';

class AuthRepository {
  final AppCache appCache = locator<AppCache>();
  final AuthenticationApiService auth = locator<AuthenticationApiService>();
  final CustomerService customerService = locator<CustomerService>();
  final StorageService storageService = locator<StorageService>();

  Future<AuthResponse?> register({required Customer customer}) async {
    try {
      return await auth.register(customer: customer);
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  Future<AuthResponse?> verifyEmail(
      {required String email, required int code}) async {
    try {
      return await auth.emailVerifier(email: email, code: code);
    } catch (e) {
      print("Error verifying email: $e");
      return null;
    }
  }

  Future<AuthResponse?> resendOTP({required String email}) async {
    return auth.resendOTP(email: email);
  }

  Future<AuthResponse?> login({required Customer customer}) async {
    try {
      return await auth.login(customer: customer);
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  Future<bool> forgetPassword({required String email}) async {
    try {
      return await auth.forgotPassword(email: email);
    } catch (e) {
      print("Error sending forgot password: $e");
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required int code,
    required String confirmPassword,
  }) async {
    try {
      return await auth.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      print("Error resetting password: $e");
      return false;
    }
  }

  Future<AuthResponse?> getUser() async {
    try {
      var response = await auth.getUser();
      if (response?.data?.user?.id != null) {
        await customerService.storeUser(response!.data!.user);
      }
      return response;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<Customer?> getLocalServiceDetail() async {
    try {
      String? storedData =
          await storageService.readItem(key: DbTable.customerTableName);
      print("STORED USER DATA: $storedData");
      if (storedData == null || storedData.isEmpty) return null;
      var jsonData = jsonDecode(storedData);
      return Customer.fromJson(jsonData);
    } catch (e) {
      print("Error parsing stored user data: $e");
      return null;
    }
  }

  Future<bool> changePin({
    required String userId,
    required String newPin,
    required String oldPin,
  }) async {
    try {
      return await auth.changePin(
          userId: userId, newPin: newPin, oldPin: oldPin);
    } catch (e) {
      print("Error changing PIN: $e");
      return false;
    }
  }

  Future<Customer?> uploadProfileImage(String userId, String filePath, {required String fileName}) async {
    try {
      final user = await auth.uploadProfileImage(userId, filePath);
      if (user != null) {
        print('Stored user profile image: ${user.imageUrl}');
      }
      return user;
    } catch (e) {
      print('Error uploading profile image: $e');
      showCustomToast('Failed to upload profile image.');
      return null;
    }
  }
}
