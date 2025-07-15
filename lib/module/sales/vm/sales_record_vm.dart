// import 'dart:async';
// import 'package:etegram_business/base/base_vm.dart';
// import 'package:etegram_business/core/model/sales_records.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/web/sales_api_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
//
// import '../../../service/local/user_service.dart';
//
// class SalesRecordViewModel extends BaseViewModel {
//   final SalesApiService _salesApiService = locator<SalesApiService>();
//   final ValueNotifier<List<SalesRecord>> salesHistory = ValueNotifier([]);
//   final ValueNotifier<List<SalesRecord>> owingRecords = ValueNotifier([]);
//   final ValueNotifier<List<SalesRecord>> owedRecords = ValueNotifier([]);
//   final ValueNotifier<int> totalSuppliers = ValueNotifier(0);
//   final ValueNotifier<bool> isLoading = ValueNotifier(false);
//   final ValueNotifier<int> tabIndex = ValueNotifier(0);
//   final ValueNotifier<String?> errorMessage = ValueNotifier(null);
//
//   List<String> get timeOfSale => ['Today', 'This Week', 'This Month', 'All Time'];
//   List<String> get paymentMethod => ['Cash', 'Card', 'Credit', 'Transfer'];
//   List<String> get customer => ['All Customers', 'Customer A', 'Customer B'];
//   List<String> get userSelection => ['All Users', 'User A', 'User B'];
//   List<String> get filterBySelection => ['Date', 'Total', 'Status'];
//   List<DataTab> get recordTabs => [
//     DataTab(title: 'Sales'),
//     DataTab(title: 'Owing'),
//     DataTab(title: 'Owed'),
//   ];
//
//   int get selectedIndex => tabIndex.value;
//
//   Future<void> init() async {
//     final storeId = await locator<CustomerService>().getActiveStoreId();
//     if (storeId == null) {
//       errorMessage.value = 'No active store selected.';
//       showCustomToast('No active store selected.');
//       return;
//     }
//     isLoading.value = true;
//     errorMessage.value = null;
//     print('SalesRecordViewModel: Initializing with storeId: $storeId');
//     await Future.wait([
//       fetchSalesHistory(storeId),
//       fetchOwingRecords(storeId),
//       fetchOwedRecords(storeId),
//     ]);
//     isLoading.value = false;
//   }
//
//   Future<void> fetchSalesHistory(String storeId) async {
//     try {
//       print('Fetching sales history for store: $storeId');
//       final records = await _salesApiService.getSalesHistory(storeId: storeId);
//       print('Fetched ${records.length} sales records');
//       salesHistory.value = records;
//       totalSuppliers.value = records
//           .where((record) => record.supplierId != null)
//           .map((record) => record.supplierId!)
//           .toSet()
//           .length;
//     } catch (e) {
//       print('Error fetching sales history: $e');
//       errorMessage.value = 'Failed to fetch sales history: $e';
//       showCustomToast('Failed to fetch sales history.');
//       salesHistory.value = [];
//     }
//   }
//
//   Future<void> fetchOwingRecords(String storeId) async {
//     try {
//       print('Fetching owing records for store: $storeId, supplier: all');
//       final records = await _salesApiService.getOwingRecords(storeId: storeId);
//       print('Fetched ${records.length} owing records');
//       owingRecords.value = records;
//     } catch (e) {
//       print('Error fetching owing records: $e');
//       errorMessage.value = 'Failed to fetch owing records: $e';
//       showCustomToast('Failed to fetch owing records.');
//       owingRecords.value = [];
//     }
//   }
//
//   Future<void> fetchOwedRecords(String storeId) async {
//     try {
//       print('Fetching owed records for store: $storeId, customer: all');
//       final records = await _salesApiService.getOwedRecords(storeId: storeId);
//       print('Fetched ${records.length} owed records');
//       owedRecords.value = records;
//     } catch (e) {
//       print('Error fetching owed records: $e');
//       errorMessage.value = 'Failed to fetch owed records: $e';
//       showCustomToast('Failed to fetch owed records.');
//       owedRecords.value = [];
//     }
//   }
//
//   void onQueryChanged(String query) {
//     // Implement search logic
//     showCustomToast('Search not implemented yet.');
//   }
//
//   void onTabChanged(int index) {
//     tabIndex.value = index;
//     notifyListeners();
//   }
//
//   void onchangeSelectTimeOfSales(String? value) {
//     showCustomToast('Time of sales filter not implemented yet.');
//   }
//
//   void onchangeSelectPaymentMethod(String? value) {
//     showCustomToast('Payment method filter not implemented yet.');
//   }
//
//   void onchangeSelectedCustomer(String? value) {
//     showCustomToast('Customer filter not implemented yet.');
//   }
//
//   void onchangeSelectUser(String? value) {
//     showCustomToast('User filter not implemented yet.');
//   }
//
//   void onchangeSelectFilteredBy(String? value) {
//     showCustomToast('Sort by filter not implemented yet.');
//   }
//
//   @override
//   void dispose() {
//     salesHistory.dispose();
//     owingRecords.dispose();
//     owedRecords.dispose();
//     totalSuppliers.dispose();
//     isLoading.dispose();
//     tabIndex.dispose();
//     errorMessage.dispose();
//     super.dispose();
//   }
// }


import 'dart:async';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/sales_records.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/service/web/sales_api_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../service/local/user_service.dart';

class SalesRecordViewModel extends BaseViewModel {
  final SalesApiService _salesApiService = locator<SalesApiService>();
  final ValueNotifier<List<SalesRecord>> salesHistory = ValueNotifier([]);
  final ValueNotifier<List<SalesRecord>> owingRecords = ValueNotifier([]);
  final ValueNotifier<List<SalesRecord>> owedRecords = ValueNotifier([]);
  final ValueNotifier<int> totalSuppliers = ValueNotifier(0);
  final ValueNotifier<double> totalOwing = ValueNotifier(0.0);
  final ValueNotifier<int> totalCustomers = ValueNotifier(0);
  final ValueNotifier<double> totalOwed = ValueNotifier(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> tabIndex = ValueNotifier(0);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  List<String> get timeOfSale => ['Today', 'This Week', 'This Month', 'All Time'];
  List<String> get paymentMethod => ['Cash', 'Card', 'Credit', 'Transfer'];
  List<String> get customer => ['All Customers', 'Customer A', 'Customer B'];
  List<String> get userSelection => ['All Users', 'User A', 'User B'];
  List<String> get filterBySelection => ['Date', 'Total', 'Status'];
  List<DataTab> get recordTabs => [
    DataTab(title: 'Sales'),
    DataTab(title: 'Owing'),
    DataTab(title: 'Owed'),
  ];

  int get selectedIndex => tabIndex.value;

  Future<void> init() async {
    final storeId = await locator<CustomerService>().getActiveStoreId();
    if (storeId == null) {
      errorMessage.value = 'No active store selected.';
      showCustomToast('No active store selected.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    print('SalesRecordViewModel: Initializing with storeId: $storeId');
    await Future.wait([
      fetchSalesHistory(storeId),
      fetchOwingRecords(storeId),
      fetchOwedRecords(storeId),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchSalesHistory(String storeId) async {
    try {
      print('Fetching sales history for store: $storeId');
      final records = await _salesApiService.getSalesHistory(storeId: storeId);
      print('Fetched ${records.length} sales records');
      salesHistory.value = records;
      totalSuppliers.value = records
          .where((record) => record.supplierId != null)
          .map((record) => record.supplierId!)
          .toSet()
          .length;
    } catch (e) {
      print('Error fetching sales history: $e');
      errorMessage.value = 'Failed to fetch sales history: $e';
      showCustomToast('Failed to fetch sales history.');
      salesHistory.value = [];
    }
  }

  Future<void> fetchOwingRecords(String storeId) async {
    try {
      print('Fetching owing records for store: $storeId, supplier: all');
      final records = await _salesApiService.getOwingRecords(storeId: storeId);
      print('Fetched ${records.length} owing records');
      owingRecords.value = records;
      totalOwing.value = records.fold(
          0.0, (sum, record) => sum + (record.totalPriceWithTax ?? 0.0));
    } catch (e) {
      print('Error fetching owing records: $e');
      errorMessage.value = 'Failed to fetch owing records: $e';
      showCustomToast('Failed to fetch owing records.');
      owingRecords.value = [];
      totalOwing.value = 0.0;
    }
  }

  Future<void> fetchOwedRecords(String storeId) async {
    try {
      print('Fetching owed records for store: $storeId, customer: all');
      final records = await _salesApiService.getOwedRecords(storeId: storeId);
      print('Fetched ${records.length} owed records');
      owedRecords.value = records;
      totalOwed.value = records.fold(
          0.0, (sum, record) => sum + (record.totalPriceWithTax ?? 0.0));
      totalCustomers.value = records
          .where((record) => record.customerId != null)
          .map((record) => record.customerId!)
          .toSet()
          .length;
    } catch (e) {
      print('Error fetching owed records: $e');
      errorMessage.value = 'Failed to fetch owed records: $e';
      showCustomToast('Failed to fetch owed records.');
      owedRecords.value = [];
      totalOwed.value = 0.0;
      totalCustomers.value = 0;
    }
  }

  void onQueryChanged(String query) {
    showCustomToast('Search not implemented yet.');
  }

  void onTabChanged(int index) {
    tabIndex.value = index;
    notifyListeners();
  }

  void onchangeSelectTimeOfSales(String? value) {
    showCustomToast('Time of sales filter not implemented yet.');
  }

  void onchangeSelectPaymentMethod(String? value) {
    showCustomToast('Payment method filter not implemented yet.');
  }

  void onchangeSelectedCustomer(String? value) {
    showCustomToast('Customer filter not implemented yet.');
  }

  void onchangeSelectUser(String? value) {
    showCustomToast('User filter not implemented yet.');
  }

  void onchangeSelectFilteredBy(String? value) {
    showCustomToast('Sort by filter not implemented yet.');
  }

  @override
  void dispose() {
    salesHistory.dispose();
    owingRecords.dispose();
    owedRecords.dispose();
    totalSuppliers.dispose();
    totalOwing.dispose();
    totalCustomers.dispose();
    totalOwed.dispose();
    isLoading.dispose();
    tabIndex.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
