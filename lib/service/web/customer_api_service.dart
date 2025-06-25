// customer_api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/customer_response.dart'; // This needs to be correctly defined
import 'package:etegram_business/core/model/store_model.dart';
import 'package:etegram_business/service/web/base_api.dart';
import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';

class CustomerApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  // MODIFIED: Return type changed to Future<CustomerData?>
  Future<CustomerData?> createCustomer({required CustomerData data}) async {
    final payload = {
      'firstName': data.firstName,
      'lastName': data.lastName,
      'email': data.email,
      'phoneNumber': data.phoneNumber,
      'address': data.address,
      'country': data.country,
      'state': data.state,
      'lga': data.lga,
      'area': data.area,
      'birthday': data.birthday,
      'storeId': data.storeId,
      'extraPhone': data.extraPhone,
      'extraDetails': data.extraDetails,
    };
    try {
      Response response =
      await connect().post(AppUrls.createCustomerUrl, data: payload);
      // MODIFIED: Extract CustomerData directly from the CustomerResponse
      final customerResponse = CustomerResponse.fromJson(response.data);
      return customerResponse.data?.first; // Assuming 'data' contains a list with one item
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }

  // MODIFIED: Return type changed to Future<CustomerData?>
  Future<CustomerData?> updateCustomer(
      String customerId, CustomerData data) async {
    final payload = {
      'firstName': data.firstName,
      'lastName': data.lastName,
      'email': data.email,
      'phoneNumber': data.phoneNumber,
      'address': data.address,
      'country': data.country,
      'state': data.state,
      'lga': data.lga,
      'area': data.area,
      'birthday': data.birthday,
      'storeId': data.storeId,
      'extraPhone': data.extraPhone,
      'extraDetails': data.extraDetails,
    };
    try {
      Response response = await connect()
          .put('${AppUrls.createCustomerUrl}/$customerId', data: payload);
      // MODIFIED: Extract CustomerData directly from the CustomerResponse
      final customerResponse = CustomerResponse.fromJson(response.data);
      return customerResponse.data?.first; // Assuming 'data' contains a list with one item
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }

  Future<List<CustomerData>?> getAllCustomer(
      {String? storeId, String? keyword, int page = 1, int limit = 20}) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (storeId != null) queryParameters['storeId'] = storeId;
      if (keyword != null) queryParameters['keyword'] = keyword;
      Response response = await connect()
          .get(AppUrls.createCustomerUrl, queryParameters: queryParameters);
      return CustomerResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }

  Future<CustomerResponse?> getUpcomingBirthdays(
      {String? storeId, int? month}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (storeId != null) queryParameters['storeId'] = storeId;
      if (month != null) queryParameters['month'] = month.toString();
      Response response = await connect().get(
        '${AppUrls.createCustomerUrl}/birthdays',
        queryParameters: queryParameters,
      );
      // This expects CustomerResponse.data to be a list
      return CustomerResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }

  // MODIFIED: Ensure getACustomer correctly extracts single CustomerData
  Future<CustomerData?> getACustomer(String customerId) async {
    if (customerId.isEmpty) return null;
    try {
      Response response =
      await connect().get('${AppUrls.createCustomerUrl}/$customerId');
      // MODIFIED: Parse as CustomerResponse first, then extract the single item
      final customerResponse = CustomerResponse.fromJson(response.data);
      return customerResponse.data?.first; // Access the first item in the list
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      await connect().delete('${AppUrls.createCustomerUrl}/$customerId');
      return true;
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return false;
    }
  }

  Future<List<Store>?> getStores() async {
    try {
      Response response = await connect().get(AppUrls.createStoreUrl);
      return (response.data['data'] as List)
          .map((e) => Store.fromJson(e))
          .toList();
    } on DioException catch (e) {
      print('Dio error: ${e.response}');
      return null;
    }
  }
}
