// // review_screen.dart
// import 'package:flutter/material.dart';
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/core/model/cart_item.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/model/get_scan_response.dart';
// import '../view/widgets/review_card.dart';
//
//
// class ReviewScreen extends StatelessWidget {
//   final List<Cart> cartItems;
//
//   const ReviewScreen({super.key, required this.cartItems});
//
//   @override
//   Widget build(BuildContext context) {
//     final model = locator<SaleViewModel>();
//     final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
//
//     return Scaffold(
//       backgroundColor: ColorValues.backgroundColor,
//       appBar: CustomAppBar(
//         title: 'Review Order',
//         onBackPressed: navigationService.goBack,
//         showMenuIcon: false,
//       ),
//       body: Padding(
//         padding: 16.0.padA,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppText(
//               'Order Summary',
//               style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
//             ),
//             20.0.sbH,
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartItems[index];
//                   return Padding(
//                     padding: 8.0.padV,
//                     child: ReviewCard(
//                       productName: item.name ?? 'Unnamed Product',
//                       quantity: item.quantity,
//                       amount: item.price.toDouble(),
//                       total: item.subtotal.toDouble(),
//                       size: item.size ?? "Unknown Size",
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Divider(),
//             AppText(
//               'Total: ${nairaFormat.format(model.calculateTotalPrice())}', // ✅ Formatted properly
//               style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
//             ),
//             20.0.sbH,
//             AppButton(
//               text: 'Proceed to Payment',
//               onTap: () => navigationService.navigateTo(paymentScreenRoute, arguments: {
//                 'totalAmount': model.calculateTotalPrice(),
//                 'cartItems': cartItems,
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
//
//
//
//

import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/cart_item.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:intl/intl.dart';
import '../../../core/model/get_scan_response.dart';
import '../view/widgets/review_card.dart';

class ReviewScreen extends StatelessWidget {
  final List<Cart> cartItems;

  const ReviewScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final model = locator<SaleViewModel>();
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: 'Review Order',
        onBackPressed: navigationService.goBack,
        showMenuIcon: false,
      ),
      body: Padding(
        padding: 16.0.padA,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Order Summary',
              style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
            ),
            20.0.sbH,
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Padding(
                    padding: 8.0.padV,
                    child: ReviewCard(
                      productName: item.name ?? 'Unnamed Product',
                      quantity: item.quantity,
                      amount: item.price.toDouble(),
                      total: item.subtotal.toDouble(),
                      size: item.size ?? "Unknown Size",
                    ),
                  );
                },
              ),
            ),
            Divider(),
            AppText(
              'Total: ${nairaFormat.format(model.calculateTotalPrice())}',
              style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
            ),
            20.0.sbH,
            AppButton(
              text: 'Proceed to Payment',
              onTap: () =>
                  navigationService.navigateTo(paymentScreenRoute, arguments: {
                'totalAmount': model.calculateTotalPrice(),
                'cartItems': cartItems,
              }),
            ),
          ],
        ),
      ),
    );
  }
}
