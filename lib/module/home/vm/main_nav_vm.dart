import 'package:flutter/material.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/module/home/views/home_view.dart';
import 'package:etegram_business/module/sales/view/new_sales_view.dart';
import 'package:etegram_business/module/product/view/product_view.dart';
import 'package:etegram_business/module/account/views/account_view.dart';

class MainNavViewModel extends BaseViewModel {
  int _selectedPage = 0;
  int get selectedPage => _selectedPage;

  final List<Widget> _pages = [
    const HomeView(),
    const NewSalesView(),
    const ProductView(),
    const AccountView(),
  ];
  List<Widget> get pages => _pages;

  MainNavViewModel() {
    print('MainNavViewModel: Created instance ${hashCode}');
  }

  void init(int initialIndex) {
    _selectedPage = initialIndex;
    notifyListeners();
    print(
        'MainNavViewModel: Initialized with index $initialIndex, instance: ${hashCode}');
  }

  void onNavigationItem(int index) {
    _selectedPage = index;
    notifyListeners();
    print(
        'MainNavViewModel: Navigation item selected: $index, instance: ${hashCode}');
  }

  @override
  void dispose() {
    print('MainNavViewModel: Disposing instance ${hashCode}');
    super.dispose();
  }
}
