import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:flutter/material.dart';

class AllExpenses extends StatelessWidget {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    var homeViewModel = locator<HomeViewModel>();
    return BaseView<ExpensesViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, logic, child) => Scaffold(
        key: homeViewModel.scaffoldKey,
        drawer: NavDrawer(),
        appBar: CustomAppBar(
          title: "All Expenses",
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: true,
          onMenuPressed: () => homeViewModel.openDrawer(),
        ),
      ),
    );
  }
}
