import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/service/web/base_api.dart';

import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';

class CustomerApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<CustomerResponse?> createCustomer({required CustomerData data}) async {
    final payload = {
      "firstName": data.firstName,
      "lastName": data.lastName,
      "email": data.email,
      "phoneNumber": data.phoneNumber,
      "address": data.address,
      "country": data.country,
      "birthday": DateTime(2000, 5, 15).toIso8601String(),
      "lga": data.lga,
      "area": data.area
    };
    try {
      Response response =
          await connect().post(AppUrls.createCustomerUrl, data: payload);
      CustomerResponse dataResponse = CustomerResponse.fromJson(response.data);
      return dataResponse;
    } on DioException catch (e) {
      print(e.response);
      return null;
    }
  }

  Future<List<CustomerData>?> getAllCustomer() async {
    try {
      Response response = await connect().get(AppUrls.createCustomerUrl);

      // Decode the JSON string to a Map<String, dynamic>
      Map<String, dynamic> decodedData = json.decode(response.data);

      // Parse the decoded data
      CustomerResponse customerResponse =
          CustomerResponse.fromJson(decodedData);

      return customerResponse.data; // Return the list of customers
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print('Json Decode Error: $e');
      return null;
    }
  }

  Future<CustomerData?> getACustomer(String customerId) async {
    try {
      Response response = await connect().get("customer/$customerId");

      // Decode the JSON string to a Map<String, dynamic>
      Map<String, dynamic> decodedData = json.decode(response.data);

      CustomerData responseData = CustomerData.fromJson(decodedData);

      return responseData;
    } on DioException catch (e) {
      print(e.response);
      return null;
    } catch (e) {
      print("JSON decoding error: $e");
      return null;
    }
  }
}
