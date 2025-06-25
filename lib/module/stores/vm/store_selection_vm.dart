// Store Selection ViewModel
import 'package:flutter/material.dart';

import '../../../base/base_vm.dart';
import '../../../core/model/store_model.dart';
import '../../../locator.dart';
import '../../../service/local/user_service.dart';
import '../../../utils/snack_message.dart';

class StoreSelectionViewModel extends BaseViewModel {
  final CustomerService customerService = locator<CustomerService>();
  List<Store> get stores => customerService.stores;
  String? get activeStoreId => customerService.activeStoreId;

  Future<void> fetchStores() async {
    startLoader();
    try {
      await customerService.fetchStores();
    } catch (e) {
      showCustomToast("Failed to fetch stores: $e");
    } finally {
      stopLoader();
      notifyListeners();
    }
  }

  void setActiveStore(String storeId, BuildContext context) {
    customerService.setActiveStore(storeId);
    customerService.checkUserSetup(); // Re-check setup
    notifyListeners();
  }
}
