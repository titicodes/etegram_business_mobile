import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
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
      _viewModel.temporaryDeliveryAddress = widget.deliveryAddress!.trim();
      print(
          'PaymentScreen: Initialized with delivery address: ${_viewModel.temporaryDeliveryAddress}');
    }
    print('PaymentScreen: Initial payment method: ${_viewModel.paymentMethod}');

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
      _expiryDateError = _expiryDateController.text.isEmpty
          ? 'Expiry date is required'
          : !_expiryDateController.text.contains(RegExp(r'^\d{2}/\d{2}$'))
              ? 'Format: MM/YY'
              : null;
      _cvvError = _cvvController.text.isEmpty
          ? 'CVV is required'
          : _cvvController.text.length < 3
              ? 'CVV must be at least 3 digits'
              : null;
      _bankAccountError = _bankAccountController.text.isEmpty
          ? 'Bank account is required'
          : _bankAccountController.text.length < 10
              ? 'Bank account must be at least 10 digits'
              : null;
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
                Navigator.of(context).pop();
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
          print(
              'PaymentScreen: Building with payment method: $paymentMethod, Delivery address: ${_viewModel.temporaryDeliveryAddress}');
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          onSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_expiryDateFocus),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
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
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_cvvFocus),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d/]')),
                                  LengthLimitingTextInputFormatter(5),
                                ],
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
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoading,
                  builder: (context, isLoading, _) {
                    bool isFormValid = paymentMethod == 'CASH' ||
                        (paymentMethod == 'CARD' &&
                            _cardNumberError == null &&
                            _expiryDateError == null &&
                            _cvvError == null) ||
                        (paymentMethod == 'TRANSFER' &&
                            _bankAccountError == null);
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
                                    style: normalTextStyle12.copyWith(
                                        color: Colors.red),
                                  ),
                                ),
                              AppButton(
                                text: 'Complete Payment',
                                enabled: isFormValid,
                                onTap: isFormValid
                                    ? () async {
                                        FocusScope.of(context).unfocus();
                                        final deliveryAddress = _viewModel
                                                    .temporaryDeliveryAddress
                                                    ?.trim()
                                                    .isNotEmpty ==
                                                true
                                            ? _viewModel
                                                .temporaryDeliveryAddress!
                                                .trim()
                                            : null;
                                        print(
                                            'PaymentScreen: Processing checkout with delivery address: $deliveryAddress');
                                        final result =
                                            await _viewModel.processCheckout(
                                          widget.cartItems,
                                          deliveryAddress: deliveryAddress,
                                        );
                                        if (result == null) {
                                          print(
                                              'PaymentScreen: Checkout successful');
                                          _showSuccessBottomSheet();
                                        } else {
                                          print(
                                              'PaymentScreen: Checkout failed: $result');
                                          showCustomToast(
                                              'Checkout failed: $result',
                                              success: false);
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
