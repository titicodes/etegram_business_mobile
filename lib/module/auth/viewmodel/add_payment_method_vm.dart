import 'dart:convert';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:flutter/services.dart';
import '../../../core/model/bank.dart';
import '../../../core/model/payment_method_response.dart';
import 'package:etegram_business/base/base_vm.dart';

class AddPaymentMethodViwModel extends BaseViewModel {
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  String newMethodName = '';
  String newMethodBank = '';
  String newAccountNumber = '';
  String newAccountName = '';
  String? newExtraInfo;
  bool isChecked = false;

  String? errorMessage;
  List<Bank> banks = [];
  Bank? selectedBank;

  void init() {
    fetchPaymentMethods();
    loadBanks();
  }

  void selectBank(Bank? bank) {
    selectedBank = bank;
    newMethodBank = bank?.name ?? '';
    notifyListeners();
  }

  Future<void> loadBanks() async {
    try {
      final String response = await rootBundle.loadString('assets/nigerian-banks.json');
      final data = json.decode(response);

      // Ensure the correct structure of the JSON and check if 'data' is a list or map
      if (data['data'] is List) {
        // If 'data' is a list, map it directly
        banks = (data['data'] as List)
            .map((json) => Bank.fromJson(json))
            .toList();
      } else if (data['data'] is Map) {
        // If 'data' is a map, extract values
        final Map<String, dynamic> bankMap = data['data'];
        banks = bankMap.values
            .map((json) => Bank.fromJson(json))
            .toList();
      } else {
        throw 'Unexpected data structure';
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load banks: $e';
      notifyListeners();
    }
  }



  Future<void> fetchPaymentMethods() async {
    isLoading.value = true;
    notifyListeners();
    try {
      List<PaymentMethod>? storedMethods =
          await userService.getStoredPaymentMethods();
      if (storedMethods != null) {
        paymentMethods = storedMethods;
      } else {
        paymentMethods = (await paymentMethodRepository.getPaymentMethods())!;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void updateNewMethodName(String name) {
    newMethodName = name;
    notifyListeners();
  }

  void updateAccountNumber(String accountNumber) {
    newAccountNumber = accountNumber;
    notifyListeners();
  }

  void updateAccountName(String accountName) {
    newAccountName = accountName;
    notifyListeners();
  }

  void updateExtraInfo(String? extraInfo) {
    newExtraInfo = extraInfo;
    notifyListeners();
  }

  bool canSave() {
    return newMethodName.isNotEmpty &&
        newMethodBank.isNotEmpty &&
        newAccountNumber.isNotEmpty &&
        newAccountName.isNotEmpty;
  }

  Future<void> savePaymentMethod() async {
    isLoading.value = true;
    notifyListeners();
    try {
      final newMethod = PaymentMethod(
        id: '',
        name: newMethodName,
        bank: newMethodBank,
        accountNumber: newAccountNumber,
        accountName: newAccountName,
        extraInfo: newExtraInfo,
      );
      await paymentMethodRepository.createPaymentMethod(newMethod);
      await fetchPaymentMethods(); // Refresh list
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}
