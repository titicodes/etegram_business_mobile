import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/sales/vm/new_sales_vm.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:lottie/lottie.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../base/base_ui.dart';
import '../../../core/model/get_scan_response.dart';
import '../vm/review_screen.dart';

class ScanToCheckoutView extends StatefulWidget {
  const ScanToCheckoutView({super.key});

  @override
  State<ScanToCheckoutView> createState() => _ScanToCheckoutViewState();
}

class _ScanToCheckoutViewState extends State<ScanToCheckoutView>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<SaleViewModel>(
      builder: (context, model, child) {
        print("Cart items in ScanToCheckoutView: ${model.cartItems.length}");
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: CustomAppBar(
            title: 'Cart',
            onBackPressed: navigationService.goBack,
            showMenuIcon: false,
            actions: [
              if (model.cartItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    model.clearCart(context);
                    setState(() {}); // Refresh UI
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              if (model.isLoading.value)
                Center(
                  child: Lottie.asset(
                    'assets/animations/loading.json',
                    width: 100,
                  ),
                ),
              Expanded(
                child: model.cartItems.isEmpty
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
                        initialItemCount: model.cartItems.length,
                        itemBuilder: (context, index, animation) => _buildItem(
                            context,
                            model,
                            model.cartItems[index],
                            animation,
                            index),
                      ),
              ),
              Padding(
                padding: 16.0.padA,
                child: Column(
                  children: [
                    AppText(
                      'Total: ${model.calculateTotalPrice().toStringAsFixed(2)}',
                      style: headerTextStyle.copyWith(
                          color: ColorValues.primaryColor),
                    ),
                    20.0.sbH,
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Scan More',
                            backGroundColor: Colors.grey[300],
                            textColor: Colors.black,
                            onTap: () => navigationService.navigateToWidget(
                              const CheckoutScannerView(),
                              transitionBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero)
                                      .animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          ),
                        ),
                        10.0.sbW,
                        Expanded(
                          child: AppButton(
                            text: 'Review',
                            isLoading: model.isLoading.value,
                            onTap: model.cartItems.isEmpty
                                ? null
                                : () => navigationService.navigateToWidget(
                                      ReviewScreen(cartItems: model.cartItems),
                                      transitionBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                                  begin: const Offset(1, 0),
                                                  end: Offset.zero)
                                              .animate(animation),
                                          child: child,
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, SaleViewModel model, Cart item,
      Animation<double> animation, int index) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildCartItem(context, model, item, index),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, SaleViewModel model, Cart item, int index) {
    return Card(
      elevation: 0,
      margin: 8.0.padV,
      child: ListTile(
        title: AppText(
          item.name ?? 'Unnamed Product',
          style: bodyLarge,
        ),
        subtitle: AppText(
          'Price: ${item.price.toStringAsFixed(2)} | Subtotal: ${item.subtotal.toStringAsFixed(2)}',
          style: normalTextStyle12,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                if (item.quantity <= 1) {
                  model.removeItemFromReview(item);
                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) =>
                        _buildItem(context, model, item, animation, index),
                    duration: const Duration(milliseconds: 300),
                  );
                } else {
                  model.updateItemQuantityInReview(item, item.quantity - 1);
                  setState(() {}); // Refresh UI
                }
              },
            ),
            AppText('${item.quantity}', style: bodyTextStyle),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                if (item.quantity < item.availableQuantity) {
                  model.updateItemQuantityInReview(item, item.quantity + 1);
                  setState(() {}); // Refresh UI
                } else {
                  showCustomToast('Maximum stock reached.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
