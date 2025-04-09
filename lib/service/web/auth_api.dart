import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/login_response.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../locator.dart';
import '../local/storage_service.dart';

class AuthenticationApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<AuthResponse?> register({required Customer data}) async {
    try {
      Response response = await connect().post(AppUrls.registerUrl, data: {
        "email": data.email,
        "password": data.password,
        "firstName": data.firstName,
        "lastName": data.lastName,
        "phone": data.phone,
        "country": data.country, // Add country
        "state": data.state, // Add state
        "city": data.city, // Add city
        "area": data.area, // Add area
        //"lga": data.city, // Add lga
        "currency": data.currency,
        "businessType": data.businessType,
        "businessName": data.businessName
      });
      AuthResponse? dataResponse =
          AuthResponse.fromJson(jsonDecode(response.data));
      return dataResponse;
    } on DioException catch (e) {
      print("Dio Error Response Data: ${e.response?.data}");
      return null;
    }
  }

  Future<AuthResponse?> emailVerify(
      {required String email, required int code}) async {
    try {
      print("Sending request to ${AppUrls.verifyEmailUrl}");
      print("Request data: {'email': $email, 'code': $code}");

      Response response = await connect().post(
        AppUrls.verifyEmailUrl,
        data: {"email": email, "code": code},
      );

      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      AuthResponse? dataResponse =
          AuthResponse.fromJson(jsonDecode(response.data));
      return dataResponse;
    } on DioException catch (e) {
      if (kDebugMode) {
        print("DioException: ${e.response}");
      }
      return null;
    }
  }

  Future<AuthResponse?> login({required Customer data}) async {
    try {
      Response response = await connect().post(AppUrls.loginUrl,
          data: {"email": data.email, "password": data.password});
      // Example: Storing user ID after successful login

      AuthResponse? dataResponse =
          AuthResponse.fromJson(jsonDecode(response.data));
      return dataResponse;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      Response response = await connect().post(
        AppUrls.forgotPasswordUrl,
        data: {"email": email}, // ✅ Matches ForgotPasswordDto
      );

      if (response.statusCode == 200) {
        print("✅ Forgot Password: Email sent successfully");
        return true;
      } else {
        print("⚠️ Forgot Password: HTTP error: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("❌ Forgot Password: Dio error: ${e.response?.data}");
      return false;
    }
  }

  // Reset Password API - Updates the password
  Future<bool> resetPassword({
    required String email,
    required int code, // OTP Code
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Response response = await connect().post(
        AppUrls.resetPasswordUrl,
        data: {
          "email": email, // ✅ Matches ResetPasswordDto
          "code": code, // OTP Code
          "password": newPassword,
          "confirmPassword": confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Reset Password: Password updated successfully");
        return true;
      } else {
        print("⚠️ Reset Password: HTTP error: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("❌ Reset Password: Dio error: ${e.response?.data}");
      return false;
    }
  }

  Future<Customer?> getUser() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    print("SAVED TOKEN::: $accessToken");

    if (accessToken == null) {
      print("❌ getUser: Access token is null");
      return null;
    }

    try {
      Response response = await connect().get(
        AppUrls.getUserUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      var responseData = jsonDecode(response.data);

      if (responseData['success'] == true && responseData['data'] != null) {
        var userData = responseData['data']
            ['data']; // ✅ Fix: Correctly access nested user data

        if (userData == null) {
          print("⚠️ User data is null inside response");
          return null;
        }

        Customer dataResponse = Customer.fromJson(userData);
        print("✅ Parsed Customer: ${jsonEncode(dataResponse.toJson())}");

        userService.storeUser(dataResponse);

        return dataResponse;
      }

      print("⚠️ No customer data found in response");
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        print(
            "❌ getUser: Dio error: ${e.response!.statusCode}, ${e.response!.data}");

        if (e.response!.statusCode == 403) {
          print("🚨 Forbidden: Possible token issue. Logging out...");
          await userService.logout();
        }
      } else {
        print("❌ getUser: Dio error: ${e.message}");
      }
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      Response response = await connect().post(
        AppUrls.logoutUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Logout: HTTP error: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print(
            "Logout: Dio error: ${e.response!.statusCode}, ${e.response!.data}");
      } else {
        print("Logout: Dio error: ${e.message}");
      }
      return false;
    }
  }


  Future<bool> changePin(
      {required String userId,
      required String newPin,
      required String oldPin}) async {
    try {
      // Define the payload
      final Map<String, dynamic> payload = {
        "newPin": newPin,
        "oldPin": oldPin,
      };
      // Make the API call
      Response response =
          await connect().put("user/change-pin/$userId", data: payload);

      // Handle the response if needed
      if (response.statusCode == 200) {
        print('PIN changed successfully: ${response.data}');
      } else {
        print('Failed to change PIN: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio exceptions
      print('Error occurred: $e');
    }
    return true;
  }

  Future<bool> updatePin(
      {required String userId,
        required String pin,
        required String confirmPin}) async {
    try {
      // Define the payload
      final Map<String, dynamic> payload = {
        "pin": pin,
        "confirmPin": confirmPin,
      };
      // Make the API call
      Response response =
      await connect().put("user/change-pin/$userId", data: payload);

      // Handle the response if needed
      if (response.statusCode == 200) {
        print('PIN changed successfully: ${response.data}');
      } else {
        print('Failed to change PIN: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio exceptions
      print('Error occurred: $e');
    }
    return true;
  }
}
