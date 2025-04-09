import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/supply/view_model/supply_vm.dart';
import 'package:flutter/material.dart';

class SupplyView extends StatelessWidget {
  const SupplyView({super.key});

  @override
  Widget build(BuildContext context) {
    var logic = locator<HomeViewModel>();
    return BaseView<SupplierViewModel>(
      builder: (_, model, child) => Scaffold(
        key: logic.scaffoldKey,
        drawer: NavDrawer(),
        appBar: CustomAppBar(
          title: StringValues.suppliers,
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: true,
          onMenuPressed: () {
            logic.openDrawer();
          },
        ),

      ),
    );
  }
}
