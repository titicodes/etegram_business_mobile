import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';

class BirthdaysView extends StatelessWidget {
  const BirthdaysView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      onModelReady: (model) => model.initState(),
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: "Birthdays",
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: true,
          showNotificationIcon: false,
        ),
        body: RefreshIndicator(
            onRefresh: () => model.getACustomer(),
            child: ListView.builder(itemBuilder: (context, index) {
              return NxListTile(
                showBorder: false,
                title: AppText(
                  "Remember your birthday on",
                  style: normalTextStyle,
                ),
                subtitle: AppText(
                  "On this day",
                  style: subHeaderTextStyle,
                ),
                trailing: AppText(
                  model.customer?.birthday ?? "",
                  style: normalTextStyle,
                ),
              );
            })),
      ),
    );
  }
}
