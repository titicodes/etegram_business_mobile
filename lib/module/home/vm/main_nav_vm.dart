import 'package:etegram_business/module/account/views/account_view.dart';
import 'package:etegram_business/module/sales/view/sales_view.dart';
import 'package:etegram_business/module/supply/view/list_of_suppliers.dart';
import 'package:etegram_business/module/supply/view/new_supplier.dart';
import 'package:flutter/material.dart';

import '../../../base/base_vm.dart';
import '../../product/view/product_view.dart';
import '../../sales/view/sales_record.dart';
import '../../supply/view/new_supply_view.dart';
import '../views/home_view.dart';

class MainNavViewModel extends BaseViewModel {
  int selectedPage = 0; // Initialize to 0 or a valid index

  List<Widget> pages = [];

  // Initialize the pages and selectedPage
  Future<void> init(int initialIndex) async {
    pages = [
      const HomeView(),
      const SAles(), // Placeholder for ChatHomeView or BrowseViewScreen
      const ProductView(),
      NewSupplyView(),
      const AccountView(),
    ];

    // Ensure the index is within bounds
    if (initialIndex < pages.length) {
      selectedPage = initialIndex;
    } else {
      selectedPage = 0;
    }

    notifyListeners();
  }

  void onNavigationItem(int index) {
    if (index >= 0 && index < pages.length) {
      selectedPage = index;
      notifyListeners();
    }
  }

// Other methods remain unchanged...
}
