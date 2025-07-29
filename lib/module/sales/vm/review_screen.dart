import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/style.dart';
import '../../../core/model/get_scan_response.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';
import '../view/widgets/review_card.dart';
import 'new_sales_vm.dart';

class ReviewScreen extends StatelessWidget {
  final List<Cart> cartItems;

  const ReviewScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final model = locator<SaleViewModel>();
    final Future<double> totalPriceFuture = model.calculateTotalPrice();

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
                      code: item.code,
                      quantity: item.quantity,
                      amount: item.price,
                      total: item.subtotal,
                      size: item.size ?? 'Unknown Size',
                      availableStock: item.availableQuantity,
                    ),
                  );
                },
              ),
            ),
            Divider(),
            FutureBuilder<double>(
              future: totalPriceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppText(
                    'Total: Calculating...',
                    style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
                  );
                } else if (snapshot.hasError) {
                  return AppText(
                    'Total: Error',
                    style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
                  );
                } else if (snapshot.hasData) {
                  return AppText(
                    'Total: ${nairaFormat.format(snapshot.data!)}',
                    style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
                  );
                } else {
                  return AppText(
                    'Total: ₦0.00',
                    style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
                  );
                }
              },
            ),

            20.0.sbH,
            AppButton(
              text: 'Proceed to Payment',
              onTap: () async {
                try {
                  final total = await model.calculateTotalPrice();
                  navigationService.navigateTo(
                    paymentScreenRoute,
                    arguments: {
                      'totalAmount': total,
                      'cartItems': cartItems,
                    },
                  );
                } catch (e) {
                  showCustomToast('Error calculating total: $e',
                      success: false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
