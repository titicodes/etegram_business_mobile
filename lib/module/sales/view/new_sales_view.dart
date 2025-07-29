//
//
// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/strings.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
// import 'package:etegram_business/module/home/vm/home_vm.dart';
// import 'package:etegram_business/module/product/view/search_view.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../app_widget/barcode_scanner_view.dart';
// import '../../../module/sales/view/scan_to_checkout.dart';
// import '../../../module/sales/vm/new_sales_vm.dart';
//
// class NewSalesView extends StatelessWidget {
//   const NewSalesView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final logic = locator<HomeViewModel>();
//     return BaseView<SaleViewModel>(
//       builder: (_, model, child) => Scaffold(
//         backgroundColor: ColorValues.backgroundColor,
//         key: logic.scaffoldKey,
//         drawer: const NavDrawer(),
//         appBar: CustomAppBar(
//           title: StringValues.newSales,
//           onBackPressed: () => navigationService.navigateTo(dashboardRoute),
//           showMenuIcon: true,
//           showNotificationIcon: false,
//           onMenuPressed: logic.openDrawer,
//         ),
//         body: Padding(
//           padding: 16.0.padA,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 30.0.sbH,
//                 SvgPicture.asset(SvgAssets.adsBanner),
//                 30.0.sbH,
//                 AppText(
//                   StringValues.startSale,
//                   style:
//                       headerTextStyle.copyWith(color: ColorValues.primaryColor),
//                   align: TextAlign.center,
//                 ),
//                 30.0.sbH,
//                 _buildActionButton(
//                   context,
//                   text: StringValues.tapToChech,
//                   icon: Icons.search,
//                   onTap: () => navigationService
//                       .navigateToWidget(const SearchProductView()),
//                 ),
//                 30.0.sbH,
//                 AppText(
//                   StringValues.or,
//                   style: normalTextStyle,
//                 ),
//                 20.0.sbH,
//                 _buildActionButton(
//                   context,
//                   text: "Scan Barcode",
//                   icon: Icons.qr_code_scanner,
//                   onTap: () => navigationService
//                       .navigateToWidget(const CheckoutScannerView()),
//                   child: SvgPicture.asset(SvgAssets.scan, height: 40, width: 40),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(
//     BuildContext context, {
//     required String text,
//     required IconData icon,
//     required VoidCallback onTap,
//     Widget? child,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         height: 60,
//         width: width(context),
//         decoration: BoxDecoration(
//           color: ColorValues.whiteColor,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (child != null) ...[
//               child,
//               10.0.sbW,
//             ],
//             AppText(
//               text,
//               style: normalTextStyle.copyWith(
//                 color: ColorValues.primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             10.0.sbW,
//             Icon(icon, color: ColorValues.primaryColor),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:etegram_business/app_widget/app_text.dart';
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
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../module/sales/view/scan_to_checkout.dart';
import '../../../module/sales/vm/new_sales_vm.dart';
import '../../account/views/notification_view.dart';

class NewSalesView extends StatelessWidget {
  const NewSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = locator<HomeViewModel>();
    return BaseView<SaleViewModel>(
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        key: logic.scaffoldKey,
        drawer: const NavDrawer(),
        appBar: CustomAppBar(
          title: StringValues.newSales,
          onBackPressed: () => navigationService.navigateTo(dashboardRoute),
          showMenuIcon: true,
          showNotificationIcon:
              false, // Set to true if notifications are needed
          onMenuPressed: logic.openDrawer,
          onNotificationPressed: () =>
              navigationService.navigateToWidget(const NotificationView()),
        ),
        body: Padding(
          padding: 16.0.padA,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                30.0.sbH,
                SvgPicture.asset(SvgAssets.adsBanner),
                30.0.sbH,
                AppText(
                  StringValues.startSale,
                  style:
                      headerTextStyle.copyWith(color: ColorValues.primaryColor),
                  align: TextAlign.center,
                ),
                30.0.sbH,
                _buildActionButton(
                  context,
                  text: StringValues.tapToChech,
                  icon: Icons.search,
                  onTap: () => navigationService
                      .navigateToWidget(const SearchProductView()),
                ),
                30.0.sbH,
                AppText(
                  StringValues.or,
                  style: normalTextStyle,
                ),
                20.0.sbH,
                _buildActionButton(
                  context,
                  text: "Scan Barcode",
                  icon: Icons.qr_code_scanner,
                  onTap: () => navigationService
                      .navigateToWidget(const CheckoutScannerView()),
                  child:
                      SvgPicture.asset(SvgAssets.scan, height: 40, width: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 60,
        width: width(context),
        decoration: BoxDecoration(
          color: ColorValues.whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null) ...[
              child,
              10.0.sbW,
            ],
            AppText(
              text,
              style: normalTextStyle.copyWith(
                color: ColorValues.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            10.0.sbW,
            Icon(icon, color: ColorValues.primaryColor),
          ],
        ),
      ),
    );
  }
}
