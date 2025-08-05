//
//
//
// import 'package:etegram_business/app_widget/unfocus_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'package:intl/intl.dart';
// import '../../../../app_widget/input_fields.dart';
// import '../../../../core/model/get_scan_response.dart';
//
// class PaymentScreen extends StatefulWidget {
//   final double totalAmount;
//   final List<Cart> cartItems;
//
//   const PaymentScreen({
//     super.key,
//     required this.totalAmount,
//     required this.cartItems,
//   });
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   final SaleViewModel _viewModel = locator<SaleViewModel>();
//   final TextEditingController _deliveryAddressController = TextEditingController();
//   final TextEditingController _discountController = TextEditingController();
//   final FocusNode _deliveryAddressFocus = FocusNode();
//   final FocusNode _discountFocus = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     _discountController.text = _viewModel.discount.value.toString();
//     _viewModel.discount.addListener(() {
//       _discountController.text = _viewModel.discount.value.toString();
//     });
//   }
//
//   @override
//   void dispose() {
//     _deliveryAddressController.dispose();
//     _discountController.dispose();
//     _deliveryAddressFocus.dispose();
//     _discountFocus.dispose();
//     super.dispose();
//   }
//
//   void _showSuccessBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.check_circle,
//               color: ColorValues.primaryColor,
//               size: 60,
//             ),
//             16.0.sbH,
//             AppText(
//               'Payment Successful!',
//               style: headerTextStyle.copyWith(
//                 color: ColorValues.primaryColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             8.0.sbH,
//             AppText(
//               'Your order has been placed successfully. An invoice has been sent to your email.',
//               style: bodyTextStyle,
//               align: TextAlign.center,
//             ),
//             24.0.sbH,
//             AppButton(
//               text: 'Back to Home',
//               onTap: () {
//                 Navigator.of(context).pop(); // Close bottom sheet
//                 navigationService.navigateToAndRemoveUntil(dashboardRoute);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
//     return UnFocusWidget(
//       child: Scaffold(
//         backgroundColor: ColorValues.backgroundColor,
//         appBar: CustomAppBar(
//           title: 'Payment',
//           onBackPressed: navigationService.goBack,
//           showMenuIcon: false,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: 16.0.padA,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ValueListenableBuilder<double>(
//                       valueListenable: _viewModel.discount,
//                       builder: (context, discount, child) {
//                         return FutureBuilder<double>(
//                           future: _viewModel.calculateTotalPrice(),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const SpinKitThreeBounce(
//                                 color: ColorValues.primaryColor,
//                                 size: 20.0,
//                               );
//                             }
//                             final discountedTotal = snapshot.data ?? widget.totalAmount;
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (discount > 0) ...[
//                                   AppText(
//                                     'Original Total: ${nairaFormat.format(widget.totalAmount)}',
//                                     style: bodyTextStyle.copyWith(
//                                       color: Colors.grey,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                   8.0.sbH,
//                                   AppText(
//                                     'Discounted Total: ${nairaFormat.format(discountedTotal)}',
//                                     style: headerTextStyle.copyWith(
//                                       color: ColorValues.primaryColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ] else ...[
//                                   AppText(
//                                     'Total: ${nairaFormat.format(widget.totalAmount)}',
//                                     style: headerTextStyle.copyWith(
//                                       color: ColorValues.primaryColor,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             );
//                           },
//                         );
//                       },
//                     ),
//                     20.0.sbH,
//                     AppText('Select Payment Method', style: subHeaderTextStyle),
//                     10.0.sbH,
//                     _buildPaymentOption('CASH'),
//                     _buildPaymentOption('POS'),
//                     _buildPaymentOption('TRANSFER'),
//                     20.0.sbH,
//                     FutureBuilder<String?>(
//                       future: _viewModel.customerService.getUserRole(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const SpinKitThreeBounce(
//                             color: ColorValues.primaryColor,
//                             size: 20.0,
//                           );
//                         }
//                         if (snapshot.hasData && snapshot.data!.contains('STORE_OWNER')) {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               AppText('Discount (%) optional', style: subHeaderTextStyle),
//                               10.0.sbH,
//                               AppTextField(
//                                 hint: 'Enter discount (e.g., 5 for 5%)',
//                                 controller: _discountController,
//                                 keyboardType: TextInputType.number,
//                                 focusNode: _discountFocus,
//                                 textInputAction: TextInputAction.done,
//                                 onSubmitted: (value) {
//                                   final discount = double.tryParse(value) ?? 0.0;
//                                   _viewModel.updateDiscount(discount);
//                                   FocusScope.of(context).unfocus();
//                                 },
//                               ),
//                               20.0.sbH,
//                             ],
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                     AppText('Delivery Address (Optional)', style: subHeaderTextStyle),
//                     10.0.sbH,
//                     AppTextField(
//                       controller: _deliveryAddressController,
//                       hint: 'Enter delivery address',
//                       focusNode: _deliveryAddressFocus,
//                       textInputAction: TextInputAction.done,
//                       onSubmitted: (_) {
//                         FocusScope.of(context).unfocus();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//               child: ValueListenableBuilder<bool>(
//                 valueListenable: _viewModel.isLoading,
//                 builder: (context, isLoading, child) {
//                   return isLoading
//                       ? const Center(
//                     child: SpinKitCircle(
//                       color: ColorValues.primaryColor,
//                       size: 50.0,
//                     ),
//                   )
//                       : AppButton(
//                     text: 'Complete Payment',
//                     enabled: _viewModel.paymentMethod.isNotEmpty,
//                     onTap: _viewModel.paymentMethod.isEmpty
//                         ? null
//                         : () async {
//                       FocusScope.of(context).unfocus();
//                       final result = await _viewModel.processCheckout(
//                         widget.cartItems,
//                         deliveryAddress: _deliveryAddressController.text.isNotEmpty
//                             ? _deliveryAddressController.text
//                             : null,
//                       );
//                       if (result == null) {
//                         _showSuccessBottomSheet();
//                       } else {
//                         showCustomToast('Checkout failed: $result', success: false);
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentOption(String method) {
//     return Card(
//       elevation: 0,
//       margin: 8.0.padV,
//       child: RadioListTile<String>(
//         title: AppText(
//           method == 'POS' ? 'POS (Debit/Credit Card)' : method,
//           style: bodyTextStyle,
//         ),
//         value: method,
//         groupValue: _viewModel.paymentMethod == 'CARD' ? 'POS' : _viewModel.paymentMethod,
//         onChanged: (value) {
//           _viewModel.updatePaymentMethod(value!);
//           setState(() {});
//         },
//         activeColor: ColorValues.primaryColor,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Cart> cartItems;
  final String? deliveryAddress;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    this.deliveryAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SaleViewModel _viewModel = locator<SaleViewModel>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryDateFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  final FocusNode _bankAccountFocus = FocusNode();
  String? _cardNumberError;
  String? _expiryDateError;
  String? _cvvError;
  String? _bankAccountError;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryAddress != null) {
      _viewModel.temporaryDeliveryAddress = widget.deliveryAddress;
      print('PaymentScreen: Initialized with delivery address: ${widget.deliveryAddress}');
    }
    print('PaymentScreen: Initial payment method: ${_viewModel.paymentMethod}');

    // Add listeners to update UI on text changes
    _cardNumberController.addListener(_validateForm);
    _expiryDateController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
    _bankAccountController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_validateForm);
    _expiryDateController.removeListener(_validateForm);
    _cvvController.removeListener(_validateForm);
    _bankAccountController.removeListener(_validateForm);
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _bankAccountController.dispose();
    _cardNumberFocus.dispose();
    _expiryDateFocus.dispose();
    _cvvFocus.dispose();
    _bankAccountFocus.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _cardNumberError = _cardNumberController.text.isEmpty
          ? 'Card number is required'
          : _cardNumberController.text.length < 16
          ? 'Card number must be at least 16 digits'
          : null;
      _expiryDateError = _expiryDateController.text.isEmpty ? 'Expiry date is required' : null;
      _cvvError = _cvvController.text.isEmpty
          ? 'CVV is required'
          : _cvvController.text.length < 3
          ? 'CVV must be at least 3 digits'
          : null;
      _bankAccountError = _bankAccountController.text.isEmpty ? 'Bank account is required' : null;
    });
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: ColorValues.primaryColor,
              size: 60,
            ),
            16.0.sbH,
            AppText(
              'Payment Successful!',
              style: headerTextStyle.copyWith(
                color: ColorValues.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.0.sbH,
            AppText(
              'Your order has been placed successfully. An invoice has been sent to your email.',
              style: bodyTextStyle,
              align: TextAlign.center,
            ),
            24.0.sbH,
            AppButton(
              text: 'Back to Home',
              onTap: () {
                Navigator.of(context).pop(); // Close bottom sheet
                navigationService.navigateToAndRemoveUntil(dashboardRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: 'Payment Details',
        onBackPressed: navigationService.goBack,
        showMenuIcon: false,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: ValueNotifier(_viewModel.paymentMethod),
        builder: (context, paymentMethod, _) {
          print('PaymentScreen: Building with payment method: $paymentMethod');
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: 16.0.padA,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<double>(
                        future: _viewModel.calculateTotalPrice(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SpinKitThreeBounce(
                              color: ColorValues.primaryColor,
                              size: 20.0,
                            );
                          }
                          final total = snapshot.data ?? widget.totalAmount;
                          return AppText(
                            'Total: ${nairaFormat.format(total)}',
                            style: headerTextStyle.copyWith(
                              color: ColorValues.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      20.0.sbH,
                      if (paymentMethod == 'CARD') ...[
                        AppText('Card Details', style: subHeaderTextStyle),
                        10.0.sbH,
                        AppTextField(
                          controller: _cardNumberController,
                          hint: 'Card Number',
                          keyboardType: TextInputType.number,
                          focusNode: _cardNumberFocus,
                          textInputAction: TextInputAction.next,
                          errorText: _cardNumberError,
                          onSubmitted: (_) => FocusScope.of(context).requestFocus(_expiryDateFocus),
                        ),
                        10.0.sbH,
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _expiryDateController,
                                hint: 'MM/YY',
                                keyboardType: TextInputType.datetime,
                                focusNode: _expiryDateFocus,
                                textInputAction: TextInputAction.next,
                                errorText: _expiryDateError,
                                onSubmitted: (_) => FocusScope.of(context).requestFocus(_cvvFocus),
                              ),
                            ),
                            10.0.sbW,
                            Expanded(
                              child: AppTextField(
                                controller: _cvvController,
                                hint: 'CVV',
                                keyboardType: TextInputType.number,
                                focusNode: _cvvFocus,
                                textInputAction: TextInputAction.done,
                                errorText: _cvvError,
                                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                              ),
                            ),
                          ],
                        ),
                      ] else if (paymentMethod == 'TRANSFER') ...[
                        AppText('Bank Details', style: subHeaderTextStyle),
                        10.0.sbH,
                        AppTextField(
                          controller: _bankAccountController,
                          hint: 'Bank Account Number',
                          keyboardType: TextInputType.number,
                          focusNode: _bankAccountFocus,
                          textInputAction: TextInputAction.done,
                          errorText: _bankAccountError,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoading,
                  builder: (context, isLoading, _) {
                    bool isFormValid = paymentMethod == 'CASH' ||
                        (paymentMethod == 'CARD' &&
                            _cardNumberController.text.isNotEmpty &&
                            _expiryDateController.text.isNotEmpty &&
                            _cvvController.text.isNotEmpty) ||
                        (paymentMethod == 'TRANSFER' && _bankAccountController.text.isNotEmpty);
                    return isLoading
                        ? const Center(
                      child: SpinKitCircle(
                        color: ColorValues.primaryColor,
                        size: 50.0,
                      ),
                    )
                        : Column(
                      children: [
                        if (_cardNumberError != null ||
                            _expiryDateError != null ||
                            _cvvError != null ||
                            _bankAccountError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AppText(
                              'Please fill all required fields correctly',
                              style: normalTextStyle12.copyWith(color: Colors.red),
                            ),
                          ),
                        AppButton(
                          text: 'Complete Payment',
                          enabled: isFormValid,
                          onTap: isFormValid
                              ? () async {
                            FocusScope.of(context).unfocus();
                            final result = await _viewModel.processCheckout(
                              widget.cartItems,
                              deliveryAddress: widget.deliveryAddress,
                            );
                            if (result == null) {
                              print('PaymentScreen: Checkout successful');
                              _showSuccessBottomSheet();
                            } else {
                              print('PaymentScreen: Checkout failed: $result');
                              showCustomToast('Checkout failed: $result', success: false);
                            }
                          }
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
