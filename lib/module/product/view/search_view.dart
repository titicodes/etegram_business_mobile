import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/product/view/product_details_view.dart';
import 'package:etegram_business/module/sales/view/scan_to_checkout.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:etegram_business/service/local/navigation_service.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../core/model/get_scan_response.dart';
import '../../../service/local/user_service.dart';
import '../../sales/vm/new_sales_vm.dart';
import '../vm/product_viewmodel.dart';

class SearchProductView extends StatelessWidget {
  const SearchProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      onModelReady: (model) async {
        await model.initialize();
      },
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: StringValues.tapTipSearch,
          onBackPressed: () {
            locator<NavigationService>().goBack();
          },
          showMenuIcon: false,
          showNotificationIcon: false,
          showBackButton: true,
          actions: [
            ValueListenableBuilder<List<Cart>>(
              valueListenable: locator<SaleViewModel>().cartItems,
              builder: (context, items, _) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color: items.isEmpty
                            ? Colors.grey
                            : ColorValues.primaryColor,
                      ),
                      onPressed: items.isEmpty
                          ? null
                          : () {
                              locator<NavigationService>()
                                  .navigateToWidget(const ScanToCheckoutView());
                            },
                    ),
                    if (items.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${items.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: model.searchController,
                decoration: InputDecoration(
                  hintText: 'Search products by name or barcode',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: model.searchController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            model.searchController.clear();
                            model.searchProduct('');
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  model.searchProduct(value);
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Product>>(
                valueListenable: model.allProducts,
                builder: (context, products, _) {
                  if (model.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error, size: 40),
                                  ),
                                )
                              : const Icon(Icons.inventory, size: 40),
                          title: Text(
                            product.name ?? 'Unknown Product',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.code != null)
                                Text('Code: ${product.code}'),
                              if (product.price != null)
                                Text(
                                  'Price: ${NumberFormat.currency(symbol: '₦').format(product.price)}',
                                ),
                              if (product.quantity != null)
                                Text('Quantity: ${product.quantity}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart,
                                    color: Colors.green),
                                onPressed: () {
                                  if (product.code == null) {
                                    showCustomToast('Product has no barcode.',
                                        success: false, context: context);
                                    return;
                                  }
                                  if (product.quantity == null ||
                                      product.quantity! <= 0) {
                                    showCustomToast('Product is out of stock.',
                                        success: false, context: context);
                                    return;
                                  }
                                  final saleModel = locator<SaleViewModel>();
                                  saleModel.addProductDirectly(product);
                                  // Optional: Navigate to cart view
                                  // locator<NavigationService>().navigateToWidget(const ScanToCheckoutView());
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final customerService =
                                      locator<CustomerService>();
                                  final ownerId =
                                      await customerService.getOwnerId();
                                  final storeId =
                                      await customerService.getActiveStoreId();
                                  if (ownerId != null && storeId != null) {
                                    locator<NavigationService>().navigateTo(
                                      addProductViewRoute,
                                      arguments: {
                                        'isEditing': true,
                                        'product': product,
                                        'storeId': storeId,
                                        'ownerId': ownerId,
                                      },
                                    );
                                  } else {
                                    showCustomToast(
                                        'Failed to retrieve owner or store ID',
                                        success: false,
                                        context: context);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () =>
                              locator<NavigationService>().navigateToWidget(
                            ProductDetailsView(product: product),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: ValueListenableBuilder<List<Cart>>(
          valueListenable: locator<SaleViewModel>().cartItems,
          builder: (context, items, _) {
            if (items.isEmpty) return const SizedBox.shrink();
            return FloatingActionButton(
              onPressed: () {
                locator<NavigationService>()
                    .navigateToWidget(const ScanToCheckoutView());
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (items.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${items.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
