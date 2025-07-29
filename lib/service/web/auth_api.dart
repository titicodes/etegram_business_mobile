import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mime/mime.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';
import '../../core/model/auth_response.dart';
import '../../locator.dart';
import '../../service/local/storage_service.dart';
import '../../utils/snack_message.dart';
import '../local/user_service.dart';
import 'base_api.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

class AuthenticationApiService {
  final StorageService storageService = locator<StorageService>();
  final CustomerService customerService = locator<CustomerService>();

  Future<String?> _getToken() async {
    final box = GetStorage();
    String? token = box.read(DbTable.tokenTableName);
    if (token == null) {
      showCustomToast('No authentication token found.');
      return null;
    }
    return token;
  }

  Future<AuthResponse?> register({required Customer customer}) async {
    try {
      Response response = await connect().post(AppUrls.registerUrl, data: {
        "email": customer.email,
        "password": customer.password,
        "firstName": customer.firstName,
        "lastName": customer.lastName,
        "phoneNumber": customer.phoneNumber,
        "country": customer.country,
        "state": customer.state,
        "city": customer.city,
        "area": customer.area,
        "currency": customer.currency,
        "businessType": customer.businessType,
        "businessName": customer.businessName,
      });
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Register Dio Error: ${e.response?.data}");
      rethrow;
    }
  }

  Future<AuthResponse?> emailVerifier(
      {required String email, required int code}) async {
    try {
      Response response = await connect().post(
        AppUrls.verifyEmailUrl,
        data: {"email": email, "code": code},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Verify Email Dio Error: ${e.response?.data}");
      rethrow;
    }
  }

  Future<AuthResponse?> resendOTP({required String email}) async {
    try {
      Response response = await connect().post(
        AppUrls.resendOtpUrl,
        data: {"email": email, "type": "VERIFY_EMAIL"},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Resend OTP Dio Error: ${e.response?.data}");
      rethrow;
    }
  }

  Future<AuthResponse?> login({required Customer customer}) async {
    try {
      Response response = await connect().post(
        AppUrls.loginUrl,
        data: {"email": customer.email, "password": customer.password},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("Login Dio Error: ${e.response?.data}");
      rethrow;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      Response response = await connect().post(
        AppUrls.forgotPasswordUrl,
        data: {"email": email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Forgot Password Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required int code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Response response = await connect().post(
        AppUrls.resetPasswordUrl,
        data: {
          "email": email,
          "code": code,
          "password": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Reset Password Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> changePassword({
    required String userId,
    required String newPassword,
    required String oldPassword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return false;
      }
      Response response = await connect().put(
        "${AppUrls.changePasswordUrl}/$userId",
        data: {"newPassword": newPassword, "oldPassword": oldPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Change Password Dio Error: ${e.response?.data}");
      showCustomToast(
          e.response?.data['message'] ?? 'Failed to change password',
          success: false);
      return false;
    }
  }

  Future<AuthResponse?> getUser() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);
    if (accessToken == null) {
      print("getUser: No access token");
      return null;
    }
    try {
      Response response = await connect().get(
        AppUrls.getUserUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      print("getUser Dio Error: ${e.response?.data}");
      if (e.response?.statusCode == 403) {
        await customerService.logout();
      }
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      Response response = await connect().post(
        AppUrls.logoutUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Logout Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> changePin({
    required String userId,
    required String newPin,
    required String oldPin,
  }) async {
    try {
      Response response = await connect().put(
        "user/change-pin/$userId",
        data: {"newPin": newPin, "oldPin": oldPin},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Change PIN Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> updatePin({
    required String userId,
    required String pin,
    required String confirmPin,
  }) async {
    try {
      Response response = await connect().put(
        "user/change-pin/$userId",
        data: {"pin": pin, "confirmPin": confirmPin},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Update PIN Dio Error: ${e.response?.data}");
      return false;
    }
  }

  Future<Customer?> uploadProfileImage(String userId, String filePath,
      {String? fileName}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        showCustomToast('Authentication token missing. Please log in again.',
            success: false);
        return null;
      }

      final file = File(filePath);
      if (!await file.exists() || await file.length() == 0) {
        showCustomToast('Invalid or empty file.', success: false);
        return null;
      }

      final fileExtension = fileName?.split('.').last.toLowerCase() ??
          filePath.split('.').last.toLowerCase();

// Use mimeTypeFromExtension from 'mime_type' package
      final mimeType = lookupMimeType(filePath);

      if (mimeType == null || !mimeType.startsWith('image/')) {
        showCustomToast(
            'Unsupported file format. Please use an image file (JPEG, PNG, GIF, WebP, or BMP).',
            success: false);
        return null;
      }

      final effectiveFileName = fileName ??
          'profile_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: effectiveFileName,
          contentType: MediaType.parse(mimeType), // Correct usage of MediaType
        ),
      });

      final url = 'user/$userId/profile-image';
      print(
          'Request URL: ${connect().options.baseUrl}$url'); // Print full URL for clarity
      print(
          'Request Data: FormData, File: $effectiveFileName, Content-Type: $mimeType, File Size: ${await file.length() / 1024} KB');

      final response = await connect().post(
        // Assuming connect() returns a Dio instance
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      // Handle both 200 (OK) and 201 (Created) as successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;
        // The backend response clearly shows 'imageUrl'.
        // Assuming your Customer.fromJson can directly consume 'imageUrl' as 'imageUrl' property.
        // If your Customer model has a field named `profileImageUrl` that expects `imageUrl` from API:
        // responseData['profileImageUrl'] = responseData['imageUrl']; // Uncomment if mapping is needed
        return Customer.fromJson(responseData);
      }
      showCustomToast('Unexpected response status: ${response.statusCode}',
          success: false);
      return null;
    } on DioException catch (e) {
      // Use DioException for error handling
      print('DioError uploading profile image: ${e.response?.data}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ??
              'Failed to upload profile image: ${e.response?.statusCode}'
          : 'Server error: ${e.response?.statusCode}';
      showCustomToast(errorMessage, success: false);
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      showCustomToast('Error uploading profile image: $e', success: false);
      return null;
    }
  }

  Future<bool> checkEmailVerificationStatus(String email) async {
    try {
      Response response = await connect().get(
        'user/verification-status',
        queryParameters: {'email': email},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      return data['emailVerified'] ?? true;
    } on DioException catch (e) {
      print("Check Email Verification Status Dio Error: ${e.response?.data}");
      rethrow;
    }
  }
}
