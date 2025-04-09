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
  bool isLoading = false;
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
      final String response = await rootBundle.loadString('assets/banks.json');
      final data = json.decode(response);
      final Map<String, dynamic> bankMap = data['data']; // Fix here
      banks = bankMap.values
          .map((json) => Bank.fromJson(json))
          .toList(); // Use values to convert map to list
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load banks: $e';
      notifyListeners();
    }
  }




  Future<void> fetchPaymentMethods() async {
    isLoading = true;
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
      isLoading = false;
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
    isLoading = true;
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
      isLoading = false;
      notifyListeners();
    }
  }
}
