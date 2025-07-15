import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/repository/sales_repository.dart';
import 'package:etegram_business/service/local/user_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../core/model/sales_records.dart';

class SalesRecordViewModel extends BaseViewModel {
  final SalesRepository salesRepository = locator<SalesRepository>();
  final CustomerService customerService = locator<CustomerService>();

  final ValueNotifier<int> tebIndex = ValueNotifier(0);
  final List<DataTab> recordTaps = [
    DataTab(title: 'Owing'),
    DataTab(title: 'Owed'),
  ];

  final List<String> timeOfSale = [
    'Today',
    'This Week',
    'This Month',
    'All Time'
  ];
  final List<String> paymentMethod = ['Cash', 'Card', 'Credit'];
  final List<String> customer = ['All Customers', 'Customer A', 'Customer B'];
  final List<String> staff = ['All Staff', 'Staff A', 'Staff B'];
  final List<String> filterBySelection = ['Date', 'Amount', 'Product'];
  final List<String> filterOwingRecord = ['All', 'Supplier A', 'Supplier B'];

  final ValueNotifier<List<SalesRecord>> salesHistory = ValueNotifier([]);
  final ValueNotifier<List<SalesRecord>> owingRecords = ValueNotifier([]);
  final ValueNotifier<List<SalesRecord>> owedRecords = ValueNotifier([]);
  final ValueNotifier<double> totalOwing = ValueNotifier(0.0);
  final ValueNotifier<double> totalOwed = ValueNotifier(0.0);
  final ValueNotifier<int> totalSuppliers = ValueNotifier(0);
  final ValueNotifier<int> totalCustomers = ValueNotifier(0);

  String? selectedTimeOfSale;
  String? selectedPaymentMethod;
  String? selectedCustomer;
  String? selectedStaff;
  String? selectedFilterBy;
  String? selectedSupplier;

  void init() async {
    final storeId = await customerService.getActiveStoreId();
    if (storeId == null) {
      showCustomToast('No active store selected.');
      return;
    }
    await fetchSalesData(storeId);
  }

  Future<void> fetchSalesData(String storeId) async {
    startLoader();
    try {
      final history = await salesRepository.getSalesHistory(storeId: storeId);
      final owing = await salesRepository.getOwingRecords(storeId: storeId);
      final owed = await salesRepository.getOwedRecords(storeId: storeId);

      salesHistory.value = history;
      owingRecords.value = owing;
      owedRecords.value = owed;

      totalOwing.value =
          owing.fold(0.0, (sum, record) => sum + record.totalPriceWithTax);
      totalOwed.value =
          owed.fold(0.0, (sum, record) => sum + record.totalPriceWithTax);
      totalSuppliers.value = owing.map((r) => r.supplierId).toSet().length;
      totalCustomers.value = owed.map((r) => r.customerId).toSet().length;

      print(
          'Fetched: ${history.length} sales, ${owing.length} owing, ${owed.length} owed records');
    } catch (e) {
      print('Error fetching sales data: $e');
      showCustomToast('Failed to fetch sales data.');
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void onchangeSelectTimeOfSales(String? value) {
    selectedTimeOfSale = value;
    notifyListeners();
    _filterSalesData();
  }

  void onchangeSelectPaymentMethod(String? value) {
    selectedPaymentMethod = value;
    notifyListeners();
    _filterSalesData();
  }

  void onchangeSelectedCustomer(String? value) {
    selectedCustomer = value;
    notifyListeners();
    _filterSalesData();
  }

  void onchangeSelectStaff(String? value) {
    selectedStaff = value;
    notifyListeners();
    _filterSalesData();
  }

  void onchangeSelectFilteredBy(String? value) {
    selectedFilterBy = value;
    notifyListeners();
    _filterSalesData();
  }

  void onQueryChanged(String? value) {
    selectedSupplier = value;
    notifyListeners();
    _filterSalesData();
  }

  void _filterSalesData() async {
    final storeId = await customerService.getActiveStoreId();
    if (storeId == null) return;

    startLoader();
    try {
      List<SalesRecord> filteredHistory = salesHistory.value;
      List<SalesRecord> filteredOwing = owingRecords.value;
      List<SalesRecord> filteredOwed = owedRecords.value;

      if (selectedTimeOfSale != null && selectedTimeOfSale != 'All Time') {
        final now = DateTime.now();
        DateTime startDate;
        switch (selectedTimeOfSale) {
          case 'Today':
            startDate = DateTime(now.year, now.month, now.day);
            break;
          case 'This Week':
            startDate = now.subtract(Duration(days: now.weekday - 1));
            break;
          case 'This Month':
            startDate = DateTime(now.year, now.month, 1);
            break;
          default:
            startDate = DateTime(1970);
        }
        filteredHistory = filteredHistory
            .where((r) => r.createdAt.isAfter(startDate))
            .toList();
        filteredOwing =
            filteredOwing.where((r) => r.createdAt.isAfter(startDate)).toList();
        filteredOwed =
            filteredOwed.where((r) => r.createdAt.isAfter(startDate)).toList();
      }

      if (selectedPaymentMethod != null && selectedPaymentMethod != 'All') {
        final method = selectedPaymentMethod == 'Credit'
            ? 'CREDIT'
            : selectedPaymentMethod!.toUpperCase();
        filteredHistory =
            filteredHistory.where((r) => r.paymentMethod == method).toList();
        filteredOwing =
            filteredOwing.where((r) => r.paymentMethod == method).toList();
        filteredOwed =
            filteredOwed.where((r) => r.paymentMethod == method).toList();
      }

      if (selectedCustomer != null && selectedCustomer != 'All Customers') {
        filteredOwed = filteredOwed
            .where((r) => r.customerId == selectedCustomer)
            .toList();
      }

      if (selectedSupplier != null && selectedSupplier != 'All') {
        filteredOwing = filteredOwing
            .where((r) => r.supplierId == selectedSupplier)
            .toList();
      }

      salesHistory.value = filteredHistory;
      owingRecords.value = filteredOwing;
      owedRecords.value = filteredOwed;

      totalOwing.value = filteredOwing.fold(
          0.0, (sum, record) => sum + record.totalPriceWithTax);
      totalOwed.value = filteredOwed.fold(
          0.0, (sum, record) => sum + record.totalPriceWithTax);
      totalSuppliers.value =
          filteredOwing.map((r) => r.supplierId).toSet().length;
      totalCustomers.value =
          filteredOwed.map((r) => r.customerId).toSet().length;

      notifyListeners();
    } catch (e) {
      print('Error filtering sales data: $e');
      showCustomToast('Failed to filter sales data.');
    } finally {
      stopLoader();
    }
  }

  @override
  void dispose() {
    tebIndex.dispose();
    salesHistory.dispose();
    owingRecords.dispose();
    owedRecords.dispose();
    totalOwing.dispose();
    totalOwed.dispose();
    totalSuppliers.dispose();
    totalCustomers.dispose();
    super.dispose();
  }
}
