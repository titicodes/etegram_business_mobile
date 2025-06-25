import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_widget/app_text.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/style.dart';
import '../../../core/model/product_history_model.dart';
import '../../../core/model/product_model.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../service/local/user_service.dart';
import '../vm/product_viewmodel.dart';

class ProductDetailsView extends StatelessWidget {
  final Product product;

  const ProductDetailsView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      onModelReady: (model) => model.fetchProductHistory(
          product.id!, locator<CustomerService>().activeStoreId!),
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: AppBar(
          title: Text(product.name ?? 'Product Details'),
          backgroundColor: ColorValues.backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => navigationService.goBack(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => navigationService.navigateTo(
                addProductViewRoute,
                arguments: {
                  'isEditing': true,
                  'product': product,
                  'storeId': locator<CustomerService>().activeStoreId,
                  'ownerId': locator<CustomerService>().getOwnerId(),
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => model.deleteProduct(context, product),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              if (product.imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 150,
                        color: ColorValues.greyColor,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Product Details Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        product.name ?? 'Unknown Product',
                        style: subHeaderTextStyle,
                      ),
                      const SizedBox(height: 8),
                      if (product.code != null)
                        _buildDetailRow('Code', product.code!),
                      if (product.category != null)
                        _buildDetailRow('Category', product.category!),
                      if (product.price != null)
                        _buildDetailRow(
                          'Price',
                          NumberFormat.currency(symbol: '₦', decimalDigits: 2)
                              .format(product.price),
                        ),
                      if (product.costPrice != null)
                        _buildDetailRow(
                          'Cost Price',
                          NumberFormat.currency(symbol: '₦', decimalDigits: 2)
                              .format(product.costPrice),
                        ),
                      if (product.quantity != null)
                        _buildDetailRow(
                            'Quantity', product.quantity.toString()),
                      if (product.expiryDate != null &&
                          product.expiryDate!.isNotEmpty)
                        _buildDetailRow(
                          'Expiry Date',
                          product.expiryDate!,
                          color: _isExpiringSoon(product.expiryDate!)
                              ? Colors.red
                              : Colors.black87,
                        ),
                      if (product.size != null)
                        _buildDetailRow('Size', product.size!),
                      if (product.brands != null)
                        _buildDetailRow('Brands', product.brands!),
                      if (product.description != null)
                        _buildDetailRow('Description', product.description!),
                      if (product.minQuantity != null)
                        _buildDetailRow(
                            'Min Quantity', product.minQuantity.toString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product History Section
              AppText(
                'Product History',
                style: subHeaderTextStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: model.isLoading,
                builder: (context, isLoading, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? const ShimmerHistoryList()
                        : ValueListenableBuilder<List<ProductHistory>>(
                            valueListenable: model.productHistory,
                            builder: (context, history, _) {
                              if (history.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(SvgAssets.noRecord,
                                          height: 100),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'No history available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: ColorValues.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: history.length,
                                itemBuilder: (context, index) {
                                  final entry = history[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(12.0),
                                      leading: Icon(
                                        entry.type == 'restock'
                                            ? Icons.add_box
                                            : Icons.adjust,
                                        color: ColorValues.primaryColor,
                                      ),
                                      title: Text(
                                        '${entry.type.toUpperCase()}: ${entry.quantity} units',
                                        style: normalTextStyle12.copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (entry.notes != null)
                                            Text('Notes: ${entry.notes}',
                                                style: normalTextStyle12),
                                          if (entry.createdAt != null)
                                            Text(
                                              'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(entry.createdAt!)}',
                                              style: normalTextStyle12,
                                            ),
                                        ],
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
            ],
          ),
        ),
      ),
    );
  }

  bool _isExpiringSoon(String expiryDate) {
    try {
      final date = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      return difference <= 30;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: normalTextStyle12.copyWith(fontWeight: FontWeight.w600),
          ),

          Expanded(
            child: Text(
              value,
              style: normalTextStyle12.copyWith(color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerHistoryList extends StatelessWidget {
  const ShimmerHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: Container(
                width: 24,
                height: 24,
                color: Colors.white,
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
