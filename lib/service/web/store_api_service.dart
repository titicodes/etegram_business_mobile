import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_url.dart';
import '../../constants/reuseable.dart'; // Make sure DbTable is here
import '../../core/model/store_model.dart'; // Make sure Store model is here
import 'base_api.dart'; // Assuming `connect()` comes from here

class StoreApiService {
  Future<Store?> createStore(Store store) async {
    try {
      final box = GetStorage();
      String? token = box.read(DbTable.tokenTableName);
      if (token == null) {
        throw "No authentication token found";
      }

      Response response = await connect().post(
        AppUrls.createStoreUrl,
        data: store.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        // Check if the overall response data is a Map
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;

          // Check if it contains the 'data' key and if its value is a Map
          if (responseMap.containsKey('data') &&
              responseMap['data'] is Map<String, dynamic>) {
            // Correctly pass the nested 'data' map (which is the actual store object)
            // to the Store.fromJson factory.
            print(
                "StoreApiService: Data passed to Store.fromJson: ${responseMap['data']}");
            return Store.fromJson(responseMap['data'] as Map<String, dynamic>);
          } else {
            throw "Invalid response format for createStore: Missing or invalid 'data' field.";
          }
        } else {
          throw "Invalid response format for createStore: Expected Map, got ${response.data.runtimeType}";
        }
      }
      throw "Failed to create store: ${response.statusMessage ?? 'Unknown error'}";
    } on DioException catch (e) {
      print(
          "Dio Error creating store: ${e.response?.data ?? e.message ?? e.toString()}");
      // Propagate a more specific error if available from the backend
      throw "Error creating store: ${e.response?.data['message'] ?? e.message ?? 'Unknown Dio error'}";
    } catch (e) {
      print("Unexpected Error creating store: $e");
      throw "Unexpected Error creating store: $e";
    }
  }

  Future<List<Store>?> getStoresByOwner() async {
    try {
      final box = GetStorage();
      String? token = box.read(DbTable.tokenTableName);
      if (token == null) {
        print("StoreApiService: No token found");
        return [];
      }

      final response = await connect().get(
        AppUrls
            .createStoreUrl, // Assuming this is also the endpoint for GET stores
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Stores Response (from getStoresByOwner): ${response.data}");

      // ✅ This part for getStoresByOwner was already correct
      if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List<dynamic> dataList = response.data['data'];
        final stores = dataList
            .map((e) => Store.fromJson(e as Map<String, dynamic>))
            .toList();
        return stores;
      } else {
        print(
            "Unexpected response format for getStoresByOwner: ${response.data.runtimeType}");
        return [];
      }
    } on DioException catch (e) {
      print(
          "Dio Error fetching stores: ${e.response?.data ?? e.message ?? e.toString()}");
      throw "Error fetching stores: ${e.response?.data['message'] ?? e.message ?? 'Unknown Dio error'}";
    } catch (e) {
      print("Unexpected Error fetching stores: $e");
      throw "Unexpected Error fetching stores: $e";
    }
  }

  Future<Store?> updateStore(Store store, String storeId) async {
    try {
      final box = GetStorage();
      String? token = box.read(DbTable.tokenTableName);
      if (token == null) {
        throw "No authentication token found";
      }

      Response response = await connect().put(
        '${AppUrls.createStoreUrl}/$storeId', // Assuming createStoreUrl is the base for update
        data: store.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        // Check if the overall response data is a Map
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;
          // Check if it contains the 'data' key and if its value is a Map
          if (responseMap.containsKey('data') &&
              responseMap['data'] is Map<String, dynamic>) {
            // Correctly pass the nested 'data' map to the Store.fromJson factory.
            print(
                "StoreApiService: Data passed to Store.fromJson (updateStore): ${responseMap['data']}");
            return Store.fromJson(responseMap['data'] as Map<String, dynamic>);
          } else {
            throw "Invalid response format for updateStore: Missing or invalid 'data' field.";
          }
        } else {
          throw "Invalid response format for updateStore: Expected Map, got ${response.data.runtimeType}";
        }
      }
      throw "Failed to update store: ${response.statusMessage ?? 'Unknown error'}";
    } on DioException catch (e) {
      print(
          "Dio Error updating store: ${e.response?.data ?? e.message ?? e.toString()}");
      throw "Error updating store: ${e.response?.data['message'] ?? e.message ?? 'Unknown Dio error'}";
    } catch (e) {
      print("Unexpected Error updating store: $e");
      throw "Unexpected Error updating store: $e";
    }
  }
}
