

import 'package:etegram_business/module/product/view/product_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../core/model/product_model.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../service/local/user_service.dart';
import 'add_product.dart';
import '../vm/product_viewmodel.dart';

class SearchProductView extends StatelessWidget {
  const SearchProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: AppBar(
          title: const Text('Search Products'),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => navigationService.goBack(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AppTextField(
                controller: model.searchController,
                hint: 'Search by name, code, or description',
                prefix: const Icon(Icons.search, color: ColorValues.greyColor),
                onChanged: model.searchProduct,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: model.isLoading,
                  builder: (context, isLoading, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isLoading
                          ? const ShimmerProductList()
                          : ValueListenableBuilder<List<Product>>(
                        valueListenable: model.allProducts,
                        builder: (context, products, _) {
                          if (products.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(SvgAssets.noRecord, height: 100),
                                  const SizedBox(height: 8),
                                   AppText(
                                    'No products found',
                                    style: TextStyle(fontSize: 16, color: ColorValues.greyColor),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                      errorBuilder: (context, error, stackTrace) =>
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
                                      if (product.code != null) Text('Code: ${product.code}'),
                                      if (product.price != null)
                                        Text(
                                          'Price: ${NumberFormat.currency(symbol: '₦').format(product.price)}',
                                        ),
                                      if (product.quantity != null)
                                        Text('Quantity: ${product.quantity}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final ownerId = await locator<CustomerService>().getOwnerId();
                                      if (ownerId != null) {
                                        navigationService.navigateTo(
                                          addProductViewRoute,
                                          arguments: {
                                            'isEditing': true,
                                            'product': product,
                                            'storeId': locator<CustomerService>().activeStoreId,
                                            'ownerId': ownerId,
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to retrieve owner ID'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  onTap: () => navigationService.navigateToWidget(
                                    ProductDetailsView(product: product),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerProductList extends StatelessWidget {
  const ShimmerProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}