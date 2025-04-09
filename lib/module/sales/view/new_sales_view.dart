import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/barcode_scanner_view.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewSalesView extends StatelessWidget {
  const NewSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    var logic = locator<HomeViewModel>();
    return BaseView<SaleViewModel>(
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        drawer: const NavDrawer(),
        appBar: CustomAppBar(
          title: StringValues.newSales,
          onBackPressed: navigationService.goBack,
          showMenuIcon: true,
          showNotificationIcon: false,
          onMenuPressed: () {
            logic.openDrawer();
          },
        ),
        body: Padding(
          padding: 16.0.padA,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              30.0.sbH,
              InkWell(
                onTap: () {
                  navigationService.navigateToWidget(SearchProductView());
                },
                child: Container(
                  height: 60,
                  width: width(context),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: ColorValues.whiteColor),
                  child: AppText(
                    StringValues.tapToChech,
                    style: normalTextStyle,
                  ),
                ),
              ),
              30.0.sbH,
              Center(
                child: AppText(
                  StringValues.or,
                  style: subHeaderTextStyle,
                ),
              ),

              30.0.sbH,
              InkWell(
                onTap: () {
                  navigationService.navigateToWidget(BarcodeScannerView(purpose: ScanPurpose.checkout,));
                },
                child: SvgPicture.asset(SvgAssets.scan),
              )
            ],
          ),
        ),
      ),
    );
  }
}
