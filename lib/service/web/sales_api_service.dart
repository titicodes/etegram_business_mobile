// import 'package:dio/dio.dart';
// import 'package:etegram_business/core/model/checkout_response.dart';
// import 'package:etegram_business/core/model/get_scan_response.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/local/storage_service.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/constants/app_url.dart';
// import 'package:etegram_business/core/model/sales_records.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:get_storage/get_storage.dart';
// import 'dart:convert';
//
// import '../../constants/reuseable.dart';
// import 'base_api.dart';
//
// class SalesApiService {
//   StorageService storageService = locator<StorageService>();
//   CustomerService customerService = locator<CustomerService>();
//
//   Future<String> _getToken() async {
//     final box = GetStorage();
//     String? accessToken = box.read(DbTable.tokenTableName);
//     if (accessToken == null) {
//       throw Exception('No token found');
//     }
//     return accessToken;
//   }
//
//   Future<GetScanResponse?> getScanProduct({
//     required String code,
//     required String ownerId,
//     required String storeId,
//   }) async {
//     if (code.isEmpty) {
//       print('Barcode cannot be empty');
//       return GetScanResponse(
//           success: false, message: 'Barcode cannot be empty', data: null);
//     }
//
//     final token = await _getToken();
//     try {
//       print(
//           'Checking product with barcode: $code, Owner ID: $ownerId, Store ID: $storeId');
//       final endpoint = "${AppUrls.baseUrl}checkout/check-product/$code";
//       print('Request URL: $endpoint');
//       print('Query Parameters: storeId=$storeId, ownerId=$ownerId');
//
//       Response response = await connect().get(
//         endpoint,
//         queryParameters: {'storeId': storeId, 'ownerId': ownerId},
//         options: Options(
//             headers: {'Authorization': 'Bearer $token'},
//             validateStatus: (status) => true),
//       );
//
//       print('Response Status: ${response.statusCode}');
//       print('Response Data: ${response.data}');
//
//       if (response.statusCode == 200) {
//         dynamic responseData = response.data;
//         if (responseData is String) {
//           responseData = jsonDecode(responseData);
//         }
//         if (responseData is Map<String, dynamic>) {
//           return GetScanResponse.fromJson(responseData);
//         }
//         return GetScanResponse(
//             success: false, message: 'Unexpected response format', data: null);
//       } else if (response.statusCode == 404) {
//         return GetScanResponse(
//             success: false,
//             message: 'Product with barcode $code not found in store',
//             data: null);
//       } else {
//         return GetScanResponse(
//             success: false,
//             message: 'Error ${response.statusCode}: ${response.statusMessage}',
//             data: null);
//       }
//     } on DioException catch (e) {
//       print('DioException in getScanProduct: ${e.message}');
//       print('Error Status: ${e.response?.statusCode}');
//       print('Error Data: ${e.response?.data}');
//       return GetScanResponse(
//           success: false,
//           message: 'Failed to scan product: ${e.message ?? "Unknown error"}',
//           data: null);
//     } catch (e) {
//       print('Unexpected error in getScanProduct: $e');
//       return GetScanResponse(
//           success: false, message: 'Unexpected error: $e', data: null);
//     }
//   }
//
//   Future<GetScanResponse?> checkout({
//     required List<Map<String, dynamic>> cartItems,
//     double discount = 0.0,
//     double tax = 0.0,
//     required String paymentMethod,
//     required String storeId,
//     String? customerId,
//     String? supplierId,
//   }) async {
//     final token = await _getToken();
//     var payload = {
//       'cart': cartItems,
//       'paymentMethod': paymentMethod,
//       'storeId': storeId,
//       if (customerId != null) 'customerId': customerId,
//       if (supplierId != null) 'supplierId': supplierId,
//       if (discount != 0.0) 'discount': discount,
//       if (tax != 0.0) 'tax': tax,
//     };
//
//     try {
//       print('Checkout Request URL: ${AppUrls.baseUrl}${AppUrls.createCheckout}');
//       print('Checkout Payload: $payload');
//
//       Response response = await connect().post(
//         AppUrls.createCheckout,
//         options: Options(
//             headers: {'Authorization': 'Bearer $token'},
//             validateStatus: (status) => true),
//         data: payload,
//       );
//
//       print('Checkout Response Status: ${response.statusCode}');
//       print('Checkout Response Raw Data: ${response.data}');
//
//       dynamic responseData = response.data;
//       if (responseData is String) {
//         responseData = jsonDecode(responseData);
//       }
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return GetScanResponse.fromJson(responseData as Map<String, dynamic>);
//       } else {
//         return GetScanResponse(
//             success: false,
//             message: responseData['message'] ??
//                 'Checkout failed with status code ${response.statusCode}',
//             data: null);
//       }
//     } on DioException catch (e) {
//       print('DioException in checkout: ${e.message}');
//       print('Error Status: ${e.response?.statusCode}');
//       print('Error Data: ${e.response?.data}');
//       return GetScanResponse(
//           success: false,
//           message:
//           'Checkout failed: ${e.response?.data?['message'] ?? e.message}',
//           data: null);
//     } catch (e, stackTrace) {
//       print('Unexpected error in checkout: $e\n$stackTrace');
//       return GetScanResponse(
//           success: false,
//           message: 'Unexpected error during checkout: $e',
//           data: null);
//     }
//   }
//   Future<List<SalesRecord>> getSalesHistory(
//       {required String storeId, String? productId}) async {
//     final token = await _getToken();
//     try {
//       print(
//           'Fetching sales history for store: $storeId, product: ${productId ?? 'all'}');
//       final response = await connect().get(
//         '${AppUrls.baseUrl}checkout/sales-history',
//         queryParameters: {
//           'storeId': storeId,
//           if (productId != null) 'productId': productId
//         },
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//
//       print('Sales History Response: ${response.data}');
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData['data'] is List) {
//           final List<dynamic> data = responseData['data'];
//           return data.map((item) => SalesRecord.fromJson(item)).toList();
//         } else {
//           print('Unexpected response format: ${response.data}');
//           return [];
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching sales history: $e');
//       showCustomToast('Failed to fetch sales history.');
//       return [];
//     }
//   }
//
//   Future<List<SalesRecord>> getOwingRecords(
//       {required String storeId, String? supplierId}) async {
//     final token = await _getToken();
//     try {
//       print(
//           'Fetching owing records for store: $storeId, supplier: ${supplierId ?? 'all'}');
//       final response = await connect().get(
//         '${AppUrls.baseUrl}checkout/owing',
//         queryParameters: {
//           'storeId': storeId,
//           if (supplierId != null) 'supplierId': supplierId
//         },
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//
//       print('Owing Records Response: ${response.data}');
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData['data'] is List) {
//           final List<dynamic> data = responseData['data'];
//           return data.map((item) => SalesRecord.fromJson(item)).toList();
//         } else {
//           print('Unexpected response format: ${response.data}');
//           return [];
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching owing records: $e');
//       showCustomToast('Failed to fetch owing records.');
//       return [];
//     }
//   }
//
//   Future<List<SalesRecord>> getOwedRecords(
//       {required String storeId, String? customerId}) async {
//     final token = await _getToken();
//     try {
//       print(
//           'Fetching owed records for store: $storeId, customer: ${customerId ?? 'all'}');
//       final response = await connect().get(
//         '${AppUrls.baseUrl}checkout/owed',
//         queryParameters: {
//           'storeId': storeId,
//           if (customerId != null) 'customerId': customerId
//         },
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//
//       print('Owed Records Response: ${response.data}');
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData['data'] is List) {
//           final List<dynamic> data = responseData['data'];
//           return data.map((item) => SalesRecord.fromJson(item)).toList();
//         } else {
//           print('Unexpected response format: ${response.data}');
//           return [];
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching owed records: $e');
//       showCustomToast('Failed to fetch owed records.');
//       return [];
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/checkout_response.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/storage_service.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/sales_records.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/reuseable.dart';
import 'base_api.dart';

class SalesApiService {
  final StorageService _storageService = locator<StorageService>();
  final CustomerService _customerService = locator<CustomerService>();


  Future<String?> _getToken() async {
    final box = GetStorage();
    String? accessToken = box.read(DbTable.tokenTableName);
    if (accessToken == null) {
      throw Exception('No token found');
    }
    return accessToken;
  }

  Future<GetScanResponse?> getScanProduct({
    required String code,
    required String storeId,
  }) async {
    if (code.isEmpty) {
      print('SalesApiService: Barcode cannot be empty');
      return GetScanResponse(
        success: false,
        message: 'Barcode cannot be empty',
        data: null,
      );
    }

    try {
      final token = await _getToken();
      final response = await connect().post(
        '${AppUrls.baseUrl}checkout/check-product/$code',
        data: {'storeId': storeId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('SalesApiService: Request URL: ${AppUrls.baseUrl}checkout/check-product/$code');
      print('SalesApiService: Request data: ${{'storeId': storeId}}');
      print('SalesApiService: Response status: ${response.statusCode}');
      print('SalesApiService: Response data: ${response.data}');

      final scanResponse = GetScanResponse.fromJson(response.data);
      print('SalesApiService: Parsed GetScanResponse: success=${scanResponse.success}, message=${scanResponse.message}, product=${scanResponse.data?.product?.toJson()}');

      return scanResponse;
    } catch (e, stackTrace) {
      print('SalesApiService: Error scanning product: $e\n$stackTrace');
      return GetScanResponse(
        success: false,
        message: 'Error scanning product: $e',
        data: null,
      );
    }
  }

  Future<CheckoutResponse?> checkout({
    required List<Map<String, dynamic>> cartItems,
    required double discount,
    required double tax,
    required String paymentMethod,
    required String storeId,
    String? deliveryAddress,
  }) async {
    try {
      final token = await _getToken();
      final payload = {
        'cart': cartItems,
        'discount': discount,
        'tax': tax,
        'paymentMethod': paymentMethod,
        'storeId': storeId,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty)
          'deliveryAddress': deliveryAddress,
      };

      final response = await connect().post(
        '${AppUrls.baseUrl}checkout',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('SalesApiService: Checkout request payload: $payload');
      print('SalesApiService: Checkout response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckoutResponse.fromJson(response.data);
      } else {
        return CheckoutResponse(
          success: false,
          message: response.data['message'] ?? 'Checkout failed',
          data: response.data['data'] != null
              ? CheckoutData.fromJson(response.data['data'])
              : null,
        );
      }
    } catch (e, stackTrace) {
      print('SalesApiService: Checkout error: $e\n$stackTrace');
      return CheckoutResponse(
        success: false,
        message: 'Error processing checkout: $e',
        data: null,
      );
    }
  }

  Future<List<SalesRecord>> getSalesHistory({
    required String storeId,
    String? productId,
  }) async {
    final token = await _getToken();
    try {
      print(
          'SalesApiService: Fetching sales history for store: $storeId, product: ${productId ?? 'all'}');
      final response = await connect().get(
        '${AppUrls.baseUrl}checkout/sales-history',
        queryParameters: {
          'storeId': storeId,
          if (productId != null) 'productId': productId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('SalesApiService: Sales History Response: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => SalesRecord.fromJson(item)).toList();
        } else {
          print('SalesApiService: Unexpected response format: ${response.data}');
          return [];
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('SalesApiService: Error fetching sales history: $e\n$stackTrace');
      showCustomToast('Failed to fetch sales history.');
      return [];
    }
  }

  Future<List<SalesRecord>> getOwingRecords({
    required String storeId,
    String? supplierId,
  }) async {
    final token = await _getToken();
    try {
      print(
          'SalesApiService: Fetching owing records for store: $storeId, supplier: ${supplierId ?? 'all'}');
      final response = await connect().get(
        '${AppUrls.baseUrl}checkout/owing',
        queryParameters: {
          'storeId': storeId,
          if (supplierId != null) 'supplierId': supplierId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('SalesApiService: Owing Records Response: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => SalesRecord.fromJson(item)).toList();
        } else {
          print('SalesApiService: Unexpected response format: ${response.data}');
          return [];
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('SalesApiService: Error fetching owing records: $e\n$stackTrace');
      showCustomToast('Failed to fetch owing records.');
      return [];
    }
  }

  Future<List<SalesRecord>> getOwedRecords({
    required String storeId,
    String? customerId,
  }) async {
    final token = await _getToken();
    try {
      print(
          'SalesApiService: Fetching owed records for store: $storeId, customer: ${customerId ?? 'all'}');
      final response = await connect().get(
        '${AppUrls.baseUrl}checkout/owed',
        queryParameters: {
          'storeId': storeId,
          if (customerId != null) 'customerId': customerId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      print('SalesApiService: Owed Records Response: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => SalesRecord.fromJson(item)).toList();
        } else {
          print('SalesApiService: Unexpected response format: ${response.data}');
          return [];
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('SalesApiService: Error fetching owed records: $e\n$stackTrace');
      showCustomToast('Failed to fetch owed records.');
      return [];
    }
  }
}

