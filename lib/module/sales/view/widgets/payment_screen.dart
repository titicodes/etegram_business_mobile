// payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/bottom_sheet.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/sales/view/new_sales_view.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:lottie/lottie.dart';
import 'package:etegram_business/routes/routes.dart';
import '../../../../app_widget/success_pupup_widget.dart';
import '../../../../core/model/get_scan_response.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Cart> cartItems;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SaleViewModel _viewModel = locator<SaleViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: 'Payment',
        onBackPressed: navigationService.goBack,
        showMenuIcon: false,
      ),
      body: Padding(
        padding: 16.0.padA,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Total: \u20A6${widget.totalAmount.toStringAsFixed(2)}',
              style: headerTextStyle.copyWith(color: ColorValues.primaryColor),
            ),
            20.0.sbH,
            AppText('Select Payment Method', style: subHeaderTextStyle),
            10.0.sbH,
            Expanded( // ✅ Add this wrapper
              child: ValueListenableBuilder<bool>(
                valueListenable: _viewModel.isLoading,
                builder: (context, isLoading, child) {
                  return Column(
                    children: [
                      _buildPaymentOption('Cash'),
                      _buildPaymentOption('POS'),
                      const Spacer(), // ✅ Spacer now has vertical space
                      isLoading
                          ? Center(
                        child: SpinKitCircle(
                          color: ColorValues.primaryColor,
                          size: 50.0,
                        ),
                      )
                          : AppButton(
                        text: 'Complete Payment',
                        enabled: _viewModel.paymentMethod != null,
                        onTap: _viewModel.paymentMethod == null
                            ? null
                            : () async {
                          final result = await _viewModel.processCheckout(widget.cartItems);
                          if (result == null) {
                            _showSuccessPopup();
                          } else {
                            showCustomToast('Checkout failed: $result');
                          }
                        },
                      ),
                      20.0.sbH,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildPaymentOption(String method) {
    return Card(
      elevation: 0,
      margin: 8.0.padV,
      child: RadioListTile<String>(
        title: AppText(
           method == 'POS' ? 'POS (Debit/Credit Card)' : method,
          style: bodyTextStyle,
        ),
        value: method,
        groupValue: _viewModel.paymentMethod == 'CARD' ? 'POS' : _viewModel.paymentMethod,
        onChanged: (value) {
          _viewModel.updatePaymentMethod(value!);
          setState(() {}); // Force rebuild for radio button
          print('Selected payment method: $value');
        },
        activeColor: ColorValues.primaryColor,
      ),
    );
  }

  void _showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: 'Checkout Successful!',
          subTitle: 'Your purchase was successful. An invoice has been sent to your email.',
          onTap: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: AppText('What Next?', style: headerTextStyle),
              content: AppText('Start a new sale or return to dashboard?', style: normalTextStyle),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    navigationService.navigateToWidget(NewSalesView());
                  },
                  child: Text('New Sale'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    navigationService.navigateTo(dashboardRoute);
                  },
                  child: Text('Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}