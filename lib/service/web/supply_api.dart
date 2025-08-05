import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etegram_business/core/model/supply_response.dart';
import 'package:etegram_business/service/web/base_api.dart';
import 'package:flutter/foundation.dart';
import '../../core/model/supplier.dart';
import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';

class SupplyApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService userService = locator<CustomerService>();

  Future<Supplier?> createSupplier(Supplier supplier) async {
    final Map<String, dynamic> data = {
      'businessName': supplier.businessName,
      'contactName': supplier.contactName,
      'email': supplier.email,
      'phoneNumber': supplier.phoneNumber,
      'currency': supplier.currency,
      'accountDetails': supplier.accountDetails,
      'address': supplier.address,
      'country': supplier.country,
      'state': supplier.state,
      'lga': supplier.lga,
      'area': supplier.area,
    };

    try {
      Response response = await connect().post("suppliers", data: data);

      // Debugging: Print raw response
      print("Raw Response Type: ${response.data.runtimeType}");
      print("Raw Response: ${response.data}");

      dynamic responseData = response.data;

      // ✅ Convert String to JSON if necessary
      if (responseData is String) {
        try {
          responseData = json.decode(responseData);
        } catch (e) {
          print("❌ JSON Decoding Error: $e");
          return null;
        }
      }

      // ✅ Ensure responseData is a valid Map
      if (responseData is Map<String, dynamic>) {
        final nestedData = responseData[
            'data']; // ✅ Correctly extracting the actual `data` object

        if (nestedData is Map<String, dynamic>) {
          // ✅ Directly use `_id` and create the Supplier object
          return Supplier.fromJson(nestedData);
        } else {
          print("❌ Error: Expected 'data' to be a Map but got: $nestedData");
        }
      } else {
        print("❌ Error: Response data is not a valid JSON object.");
      }
    } catch (e) {
      print("❌ General Error: $e");
    }

    return null;
  }

  Future<Supplier?> updateSupplier(Supplier supplier) async {
    try {
      Response response = await connect().patch(
        "suppliers/${supplier.id}",
        data: supplier.toJson(),
      );

      if (response.statusCode == 200) {
        return Supplier.fromJson(response.data);
      } else {
        print("Failed to update supplier. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error updating supplier: $e");
      return null;
    }
  }

  Future<Supplier?> getSupplier(String id) async {
    try {
      Response response = await connect().get("suppliers/$id");
      if (response.statusCode == 200) {
        return Supplier.fromJson(response.data);
      } else {
        print("Failed to get supplier. status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error getting supplier: $e");
      return null;
    }
  }

  Future<List<Supplier>?> getSuppliers() async {
    try {
      Response response = await connect().get("suppliers");
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((supplier) => Supplier.fromJson(supplier))
            .toList();
      } else {
        print("Failed to get suppliers. status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error getting suppliers: $e");
      return null;
    }
  }

  Future<List<SupplyResponse?>> getAllSuppliers() async {
    try {
      Response response = await connect().post("suppliers");

      // Decode the JSON response
      final List<dynamic> responseData = jsonDecode(response.data);

      // Map the JSON array to a List<SupplyResponse?>
      List<SupplyResponse?> suppliers = responseData.map((item) {
        try {
          return SupplyResponse.fromJson(item);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing supplier: $e');
          }
          return null; // Return null for invalid items
        }
      }).toList();

      return suppliers;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return []; // Return an empty list on error
    }
  }
}
