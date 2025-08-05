import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
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
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
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
                          TextField(
                            controller: _deliveryAddressController,
                            decoration: InputDecoration(
                              labelText: 'Delivery Address (Optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              model.temporaryDeliveryAddress =
                                  value.isEmpty ? null : value;
                              print(
                                  'ReviewScreen: Updated delivery address: ${model.temporaryDeliveryAddress}');
                            },
                          ),
                          10.0.sbH,
                          ValueListenableBuilder<double>(
                            valueListenable: model.discount,
                            builder: (context, discount, _) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText('Discount:', style: normalTextStyle12),
                                AppText('$discount%', style: normalTextStyle12),
                              ],
                            ),
                          ),
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
                          20.0.sbH,
                          FutureBuilder<double>(
                            future: model.calculateTotalPrice(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return AppText(
                                  'Total: Calculating...',
                                  style: headerTextStyle.copyWith(
                                      color: ColorValues.primaryColor),
                                );
                              } else if (snapshot.hasError) {
                                return Column(
                                  children: [
                                    AppText(
                                      'Total: Error calculating total',
                                      style: headerTextStyle.copyWith(
                                          color: Colors.red),
                                    ),
                                    AppButton(
                                      text: 'Retry',
                                      onTap: () => setState(() {}),
                                      backGroundColor: Colors.grey[300],
                                      textColor: Colors.black,
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasData) {
                                return AppText(
                                  'Total: ${nairaFormat.format(snapshot.data!)}',
                                  style: headerTextStyle.copyWith(
                                      color: ColorValues.primaryColor),
                                );
                              } else {
                                return AppText(
                                  'Total: ₦0.00',
                                  style: headerTextStyle.copyWith(
                                      color: ColorValues.primaryColor),
                                );
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
