import 'package:dio/dio.dart';
import 'package:etegram_business/constants/app_url.dart';

import '../../core/model/store_model.dart';
import '../../locator.dart';
import '../local/storage_service.dart';
import '../local/user_service.dart';
import 'base_api.dart';

class StoreApiService {
  StorageService storageService = locator<StorageService>();
  CustomerService customerService = locator<CustomerService>();

  Future<Store?> createStore(Store store) async {
    try {
      Response response = await connect().post(AppUrls.createStoreUrl, data: store.toJson());
      return Store.fromJson(response.data);
    } on DioException catch (e) {
      print(e.response);
      return null;
    }
  }

  Future<List<Store>> getStoresByOwner(String ownerId) async {
    try {
      Response response = await connect().get('stores/user/$ownerId');
      List<dynamic> storeData = response.data;
      return storeData.map((json) => Store.fromJson(json)).toList();
    } on DioException catch (e) {
      print(e.response);
      return [];
    }
  }

  Future<Store?> updateStore(Store store, String storeId) async {
    try {
      // Ensure the URL is correctly formatted
      Response response = await connect().patch(
        'stores/$storeId', // Correct URL format
        data: store.toJson(), // Serialize the store object to JSON
      );
      return Store.fromJson(response.data);
    } on DioException catch (e) {
      // Improve error handling
      if (e.response != null) {
        print('Error status: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
      } else {
        print('Error message: ${e.message}');
      }
      return null;
    }
  }

}
