import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Use material.dart for BuildContext
import 'package:flutter/services.dart'; // For rootBundle
import '../../../base/base_vm.dart';
import '../../../constants/reuseable.dart';
import '../../../core/model/bank.dart';
import '../../../core/model/payment_method_response.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';

class AddPaymentMethodViewModel extends BaseViewModel {
  List<PaymentMethod> paymentMethods = [];
  String newMethodName = '';
  String newMethodBank = '';
  String newAccountNumber = '';
  String newAccountName = '';
  String? newExtraInfo;
  String? errorMessage;
  List<Bank> banks = [];
  Bank? selectedBank;
  PaymentMethodType? selectedPaymentType;

  void init() {
    fetchPaymentMethods();
    loadBanks();
  }

  void selectBank(Bank? bank) {
    selectedBank = bank;
    newMethodBank = bank?.name ?? '';
    notifyListeners();
  }

  // <<< NEW: Method to update selected payment type
  void selectPaymentType(String? typeDisplayName) {
    if (typeDisplayName == null) {
      selectedPaymentType = null;
    } else {
      selectedPaymentType = PaymentMethodType.values.firstWhere(
        (type) => type.toDisplayName() == typeDisplayName,
        orElse: () => PaymentMethodType
            .TRANSFER, // Fallback if not found (shouldn't happen with dropdown)
      );
    }
    notifyListeners();
  }

  Future<void> loadBanks() async {
    startLoader();
    try {
      final String response =
          await rootBundle.loadString('assets/nigerian-banks.json');
      final dynamic decoded = json.decode(response);

      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('data') &&
          decoded['data'] is List) {
        final List<dynamic> banksJsonList = decoded['data'];
        banks = banksJsonList
            .map((jsonItem) => Bank.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        print("Successfully loaded ${banks.length} banks.");
      } else if (decoded is List) {
        // Fallback if JSON is a direct list
        banks = decoded
            .map((jsonItem) => Bank.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        print("Successfully loaded ${banks.length} banks (direct list).");
      } else {
        errorMessage = 'Nigerian banks JSON is not in expected format.';
        print("Actual JSON: $decoded");
      }
    } catch (e) {
      errorMessage = 'Failed to load banks: $e';
      print("ERROR loading banks: $e");
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  Future<void> fetchPaymentMethods() async {
    startLoader();
    try {
      List<PaymentMethod>? storedMethods =
          await userService.getStoredPaymentMethods();
      paymentMethods = storedMethods ??
          (await paymentMethodRepository.getPaymentMethods()) ??
          [];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      stopLoader();
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
        newAccountName.isNotEmpty &&
        selectedPaymentType !=
            null && // <<< NEW: Check if payment type is selected
        userService.activeStoreId != null;
  }

  Future<void> savePaymentMethod(BuildContext context) async {
    startLoader();
    try {
      final storeId = userService.activeStoreId;
      if (storeId == null) {
        showCustomToast("No active store selected", success: false);
        stopLoader();
        return;
      }
      if (selectedPaymentType == null) {
        // <<< NEW: Validation for payment type
        showCustomToast("Please select a payment type", success: false);
        stopLoader();
        return;
      }

      final newMethod = PaymentMethod(
        id: '',
        name: newMethodName,
        bank: newMethodBank,
        accountNumber: newAccountNumber,
        accountName: newAccountName,
        extraInfo: newExtraInfo,
        store: storeId,
        type: selectedPaymentType, // <<< Use the selected enum value
      );

      await paymentMethodRepository.createPaymentMethod(newMethod);
      await userService.storePaymentMethod(newMethod);
      showCustomToast("Payment method added successfully!", success: true);
      navigationService.navigateToAndRemoveUntil(dashboardRoute);
    } on DioException catch (e) {
      showCustomToast(
          "Failed to add payment method: ${e.response?.data['message'] ?? e.message}",
          success: false);
      print("Dio Error in savePaymentMethod: ${e.response?.data ?? e.message}");
    } catch (e) {
      showCustomToast("Failed to add payment method: $e", success: false);
      print("General Error in savePaymentMethod: $e");
    } finally {
      stopLoader();
      notifyListeners();
    }
  }
}
