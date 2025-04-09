import 'dart:convert';

import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/local/cache.dart';
import 'package:etegram_business/service/web/store_api_service.dart';

import '../constants/reuseable.dart';
import '../core/model/store_model.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class StoreRepository {
  AppCache appCache = locator<AppCache>();
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();
  StoreApiService storeApiService = locator<StoreApiService>();

  Future<Store?> createStore(Store store) async {
    var response = await storeApiService.createStore(store);
    if (response != null) {
      await storeCreatedStore(response);
    }
    return response;
  }

  storeCreatedStore(Store store) async {
    print("Storing Product: ${store.name}");
    await storageService.storeItem(
        key: DbTable.storeTableName, value: jsonEncode(store.toJson()));
  }

  Future<List<Store>> getStoresByOwner(String ownerId) async {
    var response = await storeApiService.getStoresByOwner(ownerId);
    if (response != null) {
      await storeOwner(response);
    }
    return response;
  }

  storeOwner(List<Store> stores) async {
    // Renamed 'store' to 'stores' for clarity
    print("Owner stored: ${stores.length}");

    // Convert each Store object to its JSON representation
    List<Map<String, dynamic>> storeJsonList =
        stores.map((store) => store.toJson()).toList();

    // Encode the list of JSON objects
    String encodedStores = jsonEncode(storeJsonList);

    await storageService.storeItem(
      key: DbTable.storeTableName,
      value: encodedStores,
    );
  }

  Future<Store?> updateStore(Store store, String storeId) async {
    return await storeApiService.updateStore(store, storeId);
  }
}
