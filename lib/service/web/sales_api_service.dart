import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/checkout_response.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/app_url.dart';
import '../../constants/reuseable.dart';

class SalesApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<String> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);

    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  // FIXED: Corrected getScanProduct method
  Future<GetScanResponse?> getScanProduct({
    required int? code,
    required String ownerId,
    required String storeId,
  }) async {
    if (code == null) {
      print('Barcode cannot be null');
      return GetScanResponse(
        success: false,
        message: 'Barcode cannot be null',
        data: null,
      );
    }

    final token = await _getToken();

    try {
      // Log the request details for debugging
      print(
          'Checking existence of barcode: $code, Owner ID: $ownerId, Store ID: $storeId');

      // Make sure we have the complete URL with proper path construction
      final endpoint = "checkout/scan/$code";
      print('Request URL: ${AppUrls.baseUrl}$endpoint');
      print('Query Parameters: storeId=$storeId');

      // FIXED: Use a consistent baseUrl in connect() and ensure proper URL construction
      Response response = await connect().get(
        endpoint,
        queryParameters: {
          'storeId': storeId,
          'ownerId': ownerId, // ADDED: Include ownerId in query parameters
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) =>
              true, // Accept all status codes for proper error handling
        ),
      );

      // Log response for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      // Check if the request was successful
      if (response.statusCode == 200) {
        if (response.data is String) {
          final parsed = jsonDecode(response.data);
          return GetScanResponse.fromJson(parsed);
        } else if (response.data is Map<String, dynamic>) {
          return GetScanResponse.fromJson(response.data);
        } else {
          print('Unexpected response type: ${response.data.runtimeType}');
          return GetScanResponse(
            success: false,
            message: 'Unexpected response type: ${response.data.runtimeType}',
            data: null,
          );
        }
      } else {
        // Handle 404 and other error cases
        if (response.statusCode == 404) {
          // Return a valid response object with success = false
          print(
              'DEBUG: 404 received, product not found. Trying as String barcode...');

          // ADDED: Try again with barcode as string in case backend is expecting string format
          return await _retryWithStringBarcode(
              code.toString(), ownerId, storeId, token);
        } else {
          // Handle other error status codes
          return GetScanResponse(
            success: false,
            message: 'Error ${response.statusCode}: ${response.statusMessage}',
            data: null,
          );
        }
      }
    } on DioException catch (e) {
      print('DioException in getScanProduct: ${e.message}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');

      // Return a valid response object instead of throwing
      return GetScanResponse(
        success: false,
        message: 'Failed to scan product: ${e.message ?? "Unknown error"}',
        data: null,
      );
    } catch (e) {
      print('Unexpected error in getScanProduct: $e');

      // Return a valid response object instead of throwing
      return GetScanResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  // ADDED: New method to retry with string barcode
  Future<GetScanResponse?> _retryWithStringBarcode(String barcodeAsString,
      String ownerId, String storeId, String token) async {
    try {
      print('Retrying with barcode as string: $barcodeAsString');

      final endpoint = "checkout/scan/$barcodeAsString";
      print('Retry Request URL: ${AppUrls.baseUrl}$endpoint');

      Response response = await connect().get(
        endpoint,
        queryParameters: {
          'storeId': storeId,
          'ownerId': ownerId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('Retry Response Status: ${response.statusCode}');
      print('Retry Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is String) {
          final parsed = jsonDecode(response.data);
          return GetScanResponse.fromJson(parsed);
        } else if (response.data is Map<String, dynamic>) {
          return GetScanResponse.fromJson(response.data);
        }
      }

      // If still failed, return original error
      return GetScanResponse(
        success: false,
        message:
            'Product with barcode $barcodeAsString not found in your store',
        data: null,
      );
    } catch (e) {
      print('Error in retry with string barcode: $e');
      return GetScanResponse(
        success: false,
        message: 'Failed to scan product: $e',
        data: null,
      );
    }
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    double discount = 0.0,
    double tax = 0.0,
    required String paymentMethod,
    required String storeId,
  }) async {
    final token = await _getToken();
    var payload = {
      'cart': cartItems,
      'paymentMethod': paymentMethod,
      'storeId': storeId,
    };

    if (discount != 0.0) {
      payload['discount'] = discount;
    }
    if (tax != 0.0) {
      payload['tax'] = tax;
    }

    try {
      // Log the request details for debugging
      print(
          'Checkout Request URL: ${AppUrls.baseUrl}${AppUrls.createCheckout}'); // FIXED: Use full URL
      print('Checkout Payload: $payload');

      Response response = await connect().post(
        AppUrls.createCheckout,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) =>
              true, // Accept all status codes for proper error handling
        ),
        data: payload,
      );

      // Log response for debugging
      print('Checkout Response Status: ${response.statusCode}');
      print('Checkout Response Data: ${response.data}');

      dynamic responseData = response.data;

      // Decode manually if response.data is a String
      if (responseData is String) {
        print("Received string response: $responseData");
        responseData = jsonDecode(responseData);
      }

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckoutResponse.fromJson(responseData);
      } else {
        return CheckoutResponse(
          success: false,
          message: responseData['message'] ??
              'Checkout failed with status code ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('DioException in checkout: ${e.message}');
      print('Error Status: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');

      // Return a valid response object instead of throwing
      return CheckoutResponse(
        success: false,
        message:
            'Checkout failed: ${e.response?.data?['message'] ?? e.message}',
        data: null,
      );
    } catch (e) {
      print('Unexpected error in checkout: $e');

      // Return a valid response object instead of throwing
      return CheckoutResponse(
        success: false,
        message: 'Unexpected error during checkout: $e',
        data: null,
      );
    }
  }

  Future<void> sendFcmToken(String userId, String fcmToken) async {
    final token = await _getToken();
    try {
      await connect().post(
        'users/$userId/fcm-token', // Use correct URL (or AppUrls constant)
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      throw Exception('Failed to send FCM token: ${e.message}');
    }
  }
}
