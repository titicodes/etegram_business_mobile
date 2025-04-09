import 'dart:convert';

import 'package:etegram_business/core/model/supply_response.dart';
import 'package:etegram_business/service/web/supply_api.dart';

import '../constants/reuseable.dart';
import '../core/model/supplier.dart';
import '../locator.dart';
import '../service/local/storage_service.dart';
import '../service/local/user_service.dart';

class SupplyRepository {
  CustomerService customerService = locator<CustomerService>();
  StorageService storageService = locator<StorageService>();
  SupplyApiService supplyApiService = locator<SupplyApiService>();

  Future<Supplier?> createSupplier(Supplier supplier) async {
    return await supplyApiService.createSupplier(supplier);
  }

  Future<Supplier?> updateSupplier(Supplier supplier) async {
    return await supplyApiService.updateSupplier(supplier);
  }

  Future<Supplier?> getSupplier(String id) async {
    return await supplyApiService.getSupplier(id);
  }

  Future<List<Supplier>?> getSuppliers() async{
    var response = await supplyApiService.getSuppliers();
    if(response != null){
      await  storeSupplier(response);
    }
    return null;
  }

  storeSupplier(List<Supplier> suppliers) async{
    print("Suppliers stored: ${suppliers.length}");
    List<Map<String, dynamic>> storeJsonList =
    suppliers.map((supplier) => supplier.toJson()).toList();
    String encodedStores = jsonEncode(storeJsonList);

    await storageService.storeItem(
      key: DbTable.supplierTableName,
      value: encodedStores,
    );
  }

  Future<List<SupplyResponse>?> getAllSuppliers() async{
    var response = await supplyApiService.getAllSuppliers();
    if(response != null){
      await  storeAllSupplier(response);
    }
    return null;
  }
  storeAllSupplier(List<SupplyResponse?> suppliers)async{
    print("Suppliers stored: ${suppliers.length}");
    List<Map<String, dynamic>?> storeJsonList =
    suppliers.map((supplier) => supplier?.toJson()).toList();
    String encodedStores = jsonEncode(storeJsonList);

    await storageService.storeItem(
      key: DbTable.supplierTableName,
      value: encodedStores,
    );
  }

}
