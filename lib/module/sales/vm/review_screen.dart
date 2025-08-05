import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/get_scan_response.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:lottie/lottie.dart';
import '../../../base/base_ui.dart';
import '../view/widgets/review_card.dart';
import 'new_sales_vm.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _deliveryAddressController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final FocusNode _discountFocus = FocusNode();
  String? _discountError;

  @override
  void initState() {
    super.initState();
    final model = locator<SaleViewModel>();
    _discountController.text =
        model.discount.value == 0 ? '' : model.discount.value.toString();
    _discountController.addListener(() {
      final text = _discountController.text;
      if (text.isEmpty) {
        model.updateDiscount(0.0);
        setState(() => _discountError = null);
      } else {
        final discount = double.tryParse(text);
        if (discount == null || discount < 0 || discount > 100) {
          setState(() => _discountError = 'Enter a valid discount (0-100%)');
        } else {
          model.updateDiscount(discount);
          setState(() => _discountError = null);
        }
      }
    });
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _discountController.dispose();
    _discountFocus.dispose();
    super.dispose();
  }

  void _showSuccessBottomSheet(BuildContext context) {
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
              'Order Placed Successfully!',
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
    final model = locator<SaleViewModel>();
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    return BaseView<SaleViewModel>(
      builder: (context, model, child) {
        print(
            'ReviewScreen: Model instance: ${model.hashCode}, Cart items: ${model.cartItems.value.length}');
        return Scaffold(
          backgroundColor: ColorValues.backgroundColor,
          appBar: CustomAppBar(
            title: 'Review Order',
            onBackPressed: () {
              print('ReviewScreen: Navigating back');
              navigationService.goBack();
            },
            showMenuIcon: false,
            actions: [
              ValueListenableBuilder<List<Cart>>(
                valueListenable: model.cartItems,
                builder: (context, cartItems, _) => cartItems.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          print('ReviewScreen: Clearing cart');
                          model.clearCart(context);
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          body: ValueListenableBuilder<List<Cart>>(
            valueListenable: model.cartItems,
            builder: (context, cartItems, _) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: 16.0.padA,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Order Summary',
                            style: headerTextStyle.copyWith(
                                color: ColorValues.primaryColor),
                          ),
                          20.0.sbH,
                          cartItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/animations/empty_cart.json',
                                        height: 150,
                                      ),
                                      10.0.sbH,
                                      AppText(
                                        'Your cart is empty.',
                                        style: subHeaderTextStyle,
                                      ),
                                    ],
                                  ),
                                )
                              : AnimatedList(
                                  key: _listKey,
                                  initialItemCount: cartItems.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index, animation) {
                                    final item = cartItems[index];
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        child: ReviewCard(
                                          productName:
                                              item.name ?? 'Unnamed Product',
                                          code: item.code,
                                          quantity: item.quantity,
                                          amount: item.price,
                                          total: item.subtotal,
                                          size: item.size ?? 'Unknown Size',
                                          availableStock:
                                              item.availableQuantity,
                                          onQuantityChanged: (newQuantity) {
                                            model.updateItemQuantityInReview(
                                                item, newQuantity);
                                            _listKey.currentState
                                                ?.setState(() {});
                                          },
                                          onRemove: () {
                                            model.removeItemFromReview(item);
                                            _listKey.currentState?.removeItem(
                                              index,
                                              (context, animation) =>
                                                  FadeTransition(
                                                opacity: animation,
                                                child: SizeTransition(
                                                  sizeFactor: animation,
                                                  child: ReviewCard(
                                                    productName: item.name ??
                                                        'Unnamed Product',
                                                    code: item.code,
                                                    quantity: item.quantity,
                                                    amount: item.price,
                                                    total: item.subtotal,
                                                    size: item.size ??
                                                        'Unknown Size',
                                                    availableStock:
                                                        item.availableQuantity,
                                                  ),
                                                ),
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 300),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          20.0.sbH,
                          AppText(
                            'Order Details',
                            style: subHeaderTextStyle,
                          ),
                          10.0.sbH,
                          AppTextField(
                            controller: _deliveryAddressController,
                            hint: 'Delivery Address (Optional)',
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_discountFocus),
                            onChanged: (value) {
                              model.temporaryDeliveryAddress =
                                  value.isEmpty ? null : value;
                              print(
                                  'ReviewScreen: Updated delivery address: ${model.temporaryDeliveryAddress}');
                            },
                          ),
                          10.0.sbH,
                          FutureBuilder<String?>(
                            future: model.customerService.getUserRole(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: ColorValues.primaryColor,
                                  ),
                                );
                              }
                              if (snapshot.hasData &&
                                  snapshot.data!.contains('STORE_OWNER')) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText('Discount (%) Optional',
                                        style: subHeaderTextStyle),
                                    10.0.sbH,
                                    AppTextField(
                                      controller: _discountController,
                                      hint: 'Enter discount (e.g., 5 for 5%)',
                                      keyboardType: TextInputType.number,
                                      focusNode: _discountFocus,
                                      textInputAction: TextInputAction.done,
                                      errorText: _discountError,
                                      onSubmitted: (_) =>
                                          FocusScope.of(context).unfocus(),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[\d.]')),
                                        LengthLimitingTextInputFormatter(5),
                                      ],
                                    ),
                                    10.0.sbH,
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable: model.discount,
                            builder: (context, discount, _) {
                              return FutureBuilder<double>(
                                future: model.calculateTotalPrice(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }
                                  final total = snapshot.data ?? 0.0;
                                  final originalTotal = cartItems.fold<double>(
                                      0, (sum, item) => sum + item.subtotal);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (discount > 0) ...[
                                        AppText(
                                          'Original Total: ${nairaFormat.format(originalTotal)}',
                                          style: normalTextStyle12.copyWith(
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        8.0.sbH,
                                        AppText(
                                          'Discounted Total: ${nairaFormat.format(total)}',
                                          style: normalTextStyle12.copyWith(
                                            color: ColorValues.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else ...[
                                        AppText(
                                          'Total: ${nairaFormat.format(total)}',
                                          style: normalTextStyle12.copyWith(
                                            color: ColorValues.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          10.0.sbH,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText('Tax:', style: normalTextStyle12),
                              AppText('${model.tax}%',
                                  style: normalTextStyle12),
                            ],
                          ),
                          10.0.sbH,
                          DropdownButtonFormField<String>(
                            value: model.paymentMethod,
                            decoration: InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: ['CASH', 'CARD', 'TRANSFER']
                                .map((method) => DropdownMenuItem(
                                      value: method,
                                      child: AppText(method,
                                          style: normalTextStyle12),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                model.updatePaymentMethod(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: 16.0.padA,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: model.isLoading,
                      builder: (context, isLoading, _) => AppButton(
                        text: 'Proceed to Payment',
                        isLoading: isLoading,
                        onTap: cartItems.isEmpty
                            ? null
                            : () async {
                                try {
                                  final total =
                                      await model.calculateTotalPrice();
                                  final deliveryAddress =
                                      _deliveryAddressController.text.isEmpty
                                          ? null
                                          : _deliveryAddressController.text;
                                  print(
                                      'ReviewScreen: Payment method: ${model.paymentMethod}, Total: $total');
                                  if (model.paymentMethod == 'CARD' ||
                                      model.paymentMethod == 'TRANSFER') {
                                    print(
                                        'ReviewScreen: Navigating to paymentScreenRoute for ${model.paymentMethod}');
                                    navigationService.navigateTo(
                                      paymentScreenRoute,
                                      arguments: {
                                        'totalAmount': total,
                                        'cartItems': cartItems,
                                        'deliveryAddress': deliveryAddress,
                                      },
                                    );
                                  } else {
                                    final result = await model.processCheckout(
                                      cartItems,
                                      deliveryAddress: deliveryAddress,
                                    );
                                    if (result == null) {
                                      print(
                                          'ReviewScreen: Checkout successful');
                                      _showSuccessBottomSheet(context);
                                    } else {
                                      print(
                                          'ReviewScreen: Checkout failed: $result');
                                      showCustomToast(
                                          'Checkout failed: $result',
                                          success: false,
                                          context: context);
                                    }
                                  }
                                } catch (e) {
                                  print(
                                      'ReviewScreen: Error processing checkout: $e');
                                  showCustomToast(
                                      'Error processing checkout: $e',
                                      success: false,
                                      context: context);
                                }
                              },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
