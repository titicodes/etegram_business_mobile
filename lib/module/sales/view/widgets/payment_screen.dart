import 'package:flutter/material.dart';

import '../../../../app_widget/app_button.dart';
import '../../../../app_widget/bottom_sheet.dart';
import '../../../../app_widget/custom_appbar.dart';
import '../../../../app_widget/success_pupup_widget.dart';
import '../../../../constants/reuseable.dart';
import '../../../../core/model/get_scan_response.dart';
import '../../../../locator.dart';
import '../../../../routes/routes.dart';
import '../../vm/new_sales_vm.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  final double totalAmount;
  final List<Cart> cartItems;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SaleViewModel _viewModel = locator<SaleViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Method',
        onBackPressed: navigationService.goBack,
        showMenuIcon: false,
        showNotificationIcon: false,
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (_, __) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Total Amount: ${widget.totalAmount}')),
                const SizedBox(height: 20),
                const Text('Select Payment Method:'),
                _buildPaymentOption('Cash'),
                _buildPaymentOption('POS'),
                const SizedBox(height: 20),
                Center(
                  child: _viewModel.isLoading.value
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: "Complete Payment",
                          onTap: () async {
                            final result = await _viewModel
                                .processCheckout(widget.cartItems);
                            if (result == null) {
                              _showSuccessPopup();
                            } else {
                              _showSnackbar(result);
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return RadioListTile<String>(
      title: Text(method == 'POS' ? 'POS (Debit/Credit Card)' : method),
      value: method,
      groupValue: _viewModel.paymentMethod,
      onChanged: (value) => _viewModel.updatePaymentMethod(value!),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Purchase Successful!",
          subTitle:
              "Your purchase was successful. An invoice has been sent to your email.",
          onTap: () {
            navigationService.navigateTo(dashboardRoute);
          },
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }
}
