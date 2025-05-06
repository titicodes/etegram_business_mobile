import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/barcode_scanner_view.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../base/base_ui.dart';
import '../../../constants/reuseable.dart';
import '../../../locator.dart';
import '../vm/new_sales_vm.dart';
import '../vm/review_screen.dart';

class ScanToCheckoutView extends StatefulWidget {
  final String? scannedCode;

  const ScanToCheckoutView({super.key, this.scannedCode});

  @override
  State<ScanToCheckoutView> createState() => _ScanToCheckoutViewState();
}

class _ScanToCheckoutViewState extends State<ScanToCheckoutView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = locator<SaleViewModel>();

    return BaseView<SaleViewModel>(
      onModelReady: (model) {
        if (widget.scannedCode != null) {
          model
              .checkIfProductExists(widget.scannedCode!, context)
              .then((added) {
            if (added) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added to cart')),
              );
            }
          });
        }
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(
          title: "Scan to Checkout",
          onBackPressed: () => Navigator.pop(context),
          showMenuIcon: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Scan Products for Checkout",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Expanded(
                child: model.cartItems.isEmpty
                    ? const Center(child: Text("No products in cart"))
                    : ListView.builder(
                        itemCount: model.cartItems.length,
                        itemBuilder: (context, index) {
                          final product = model.cartItems[index];
                          return ListTile(
                            title: Text(product.name ?? 'Unnamed Product'),
                            subtitle: Text("Price: ${product.price} Naira"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      model.updateItemQuantityInReview(
                                    product,
                                    (product.quantity ?? 1) - 1,
                                  ),
                                ),
                                Text("${product.quantity ?? 1}"),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      model.updateItemQuantityInReview(
                                    product,
                                    (product.quantity ?? 1) + 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              Text("Total Price: ${model.calculateTotalPrice()} Naira",
                  style: const TextStyle(fontSize: 18)),
              20.0.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppButton(
                      text: "Scan More Products",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScannerView(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AppButton(
                      text: "Proceed to Review",
                      onTap: () {
                        // Passing the cart items to the review screen
                        navigationService.navigateToWidget(
                          ReviewScreen(cartItems: model.cartItems),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
