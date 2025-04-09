// payment_screen.dart
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
  const PaymentScreen(
      {super.key, required this.totalAmount, required this.cartItems});
  final double totalAmount;
  final List<Cart> cartItems; // Receive cartItems here

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SaleViewModel _saleViewModel = locator<SaleViewModel>();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final response = await _saleViewModel.checkout(
        cartItems: widget.cartItems
            .map((item) => item.toJson())
            .toList(), // Pass cartItems from widget
        discount: _saleViewModel.discount,
        tax: _saleViewModel.tax,
        paymentMethod: _paymentMethod,
      );
      if (response != null && response.success == true) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SalesSuccessPage()),
        // );
        await showSuccessPopup();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Checkout failed: ${response?.message ?? "Unknown error"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Method',
        onBackPressed: () {
          navigationService.goBack();
        },
        showMenuIcon: false,
        showNotificationIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _saleViewModel,
              builder: (context, child) {
                return Center(
                  child: Text('Total Amount: ${widget.totalAmount}'),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Payment Method:'),
            RadioListTile<String>(
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: _paymentMethod,
              onChanged: (String? value) {
                setState(() {
                  _paymentMethod = value!;
                  _saleViewModel.updatePaymentMethod(value);
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('POS (Debit/Credit Card)'),
              value: 'POS',
              groupValue: _paymentMethod,
              onChanged: (String? value) {
                setState(() {
                  _paymentMethod = value!;
                  _saleViewModel.updatePaymentMethod(value);
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : AppButton(
                      text: "Complete Payment",
                      onTap: () => _processPayment(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  showSuccessPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigationService.navigatorKey.currentState!.context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BottomSheetScreen(
        child: SuccessfulPopUpWidget(
          title: "Purchase successfully!",
          subTitle: "Your Purchase has been successfully. Invoice had been sent to you mail",
          onTap: (){
            navigationService.navigateTo(dashboardRoute);
          },
        ),
      ),
    ).whenComplete(navigationService.goBack);
  }
}
