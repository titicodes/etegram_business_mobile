
// Modified StoreRepository
import 'dart:convert';

import '../constants/reuseable.dart';
import '../core/model/store_model.dart';
import '../locator.dart';
import '../service/local/cache.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';
import '../service/web/store_api_service.dart';

class StoreRepository {
  final AppCache appCache = locator<AppCache>();
  final CustomerService customerService = locator<CustomerService>();
  final StorageService storageService = locator<StorageService>();
  final StoreApiService storeApiService = locator<StoreApiService>();

  Future<Store?> createStore(Store store) async {
    try {
      var response = await storeApiService.createStore(store);
      if (response != null) {
        await customerService.fetchStores();
        customerService.setActiveStore(response.id!);
      }
      return response;
    } catch (e) {
      throw "Failed to create store: $e";
    }
  }

  Future<List<Store>> getStoresByOwner() async {
    try {
      var response = await storeApiService.getStoresByOwner();
      if (response != null) {
        await storageService.storeItem(
          key: DbTable.storeTableName,
          value: jsonEncode(response.map((store) => store.toJson()).toList()),
        );
        return response;
      }
      return [];
    } catch (e) {
      throw "Failed to fetch stores: $e";
    }
  }

  Future<Store?> updateStore(Store store, String storeId) async {
    try {
      var response = await storeApiService.updateStore(store, storeId);
      if (response != null) {
        await customerService.fetchStores();
      }
      return response;
    } catch (e) {
      throw "Failed to update store: $e";
    }
  }
}