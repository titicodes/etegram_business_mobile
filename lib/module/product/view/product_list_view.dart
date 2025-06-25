import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../core/model/product_model.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../service/local/user_service.dart';
import '../../../utils/snack_message.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../home/vm/home_vm.dart';
import '../vm/product_viewmodel.dart';
import 'product_details_view.dart';

class AddProductListView extends StatefulWidget {
  const AddProductListView({super.key});

  @override
  _AddProductListViewState createState() => _AddProductListViewState();
}

class _AddProductListViewState extends State<AddProductListView> {
  @override
  Widget build(BuildContext context) {
    final homeModel = locator<HomeViewModel>();
    return BaseView<ProductViewModel>(
      onModelReady: (vm) => vm.initialize(),
      builder: (context, logic, _) => Scaffold(
        key: homeModel.scaffoldKey,
        drawer: const NavDrawer(),
        backgroundColor: ColorValues.backgroundColor,
        appBar: AppBar(
          title: const Text(StringValues.productList),
          backgroundColor: ColorValues.backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => navigationService.goBack(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => homeModel.openDrawer(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => logic.initialize(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ValueListenableBuilder<double>(
                      valueListenable: logic.totalCost,
                      builder: (context, totalCostValue, _) =>
                          ValueListenableBuilder<double>(
                        valueListenable: logic.totalSellingPrice,
                        builder: (context, totalSellingPriceValue, _) =>
                            ValueListenableBuilder<int>(
                          valueListenable: logic.totalStock,
                          builder: (context, totalStockValue, _) =>
                              buildInventoryWidget(
                            context,
                            totalCost: totalCostValue,
                            totalSellingPrice: totalSellingPriceValue,
                            totalStock: totalStockValue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      prefix: const Icon(Icons.search,
                          color: ColorValues.greyColor),
                      hint: StringValues.tapToChech,
                      onTap: () => navigationService
                          .navigateToWidget(const SearchProductView()),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<int>(
                      valueListenable: logic.productTabIndex,
                      builder: (context, selectedIndex, _) => FlutterToggleTab(
                        width: 90,
                        borderRadius: 20,
                        height: 40,
                        selectedIndex: selectedIndex,
                        selectedBackgroundColors: const [
                          ColorValues.primaryColor,
                          Colors.blueAccent
                        ],
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        unSelectedTextStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        selectedLabelIndex: (index) =>
                            logic.productTabIndex.value = index,
                        isScroll: false,
                        dataTabs: logic.productTabOptions,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ValueListenableBuilder<String?>(
                  valueListenable: logic.errorMessage,
                  builder: (context, error, _) {
                    if (error != null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: logic.productTabIndex,
                builder: (context, index, _) =>
                    _buildProductTabView(context, logic, index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTabView(
      BuildContext context, ProductViewModel logic, int index) {
    switch (index) {
      case 0:
        return ValueListenableBuilder<bool>(
          valueListenable: logic.isLoading,
          builder: (context, isLoading, _) => isLoading
              ? const SliverShimmerProductList()
              : ValueListenableBuilder<List<Product>>(
                  valueListenable: logic.allProducts,
                  builder: (context, products, _) =>
                      _buildProductSliverList(context, logic, products),
                ),
        );
      case 1:
        return ValueListenableBuilder<bool>(
          valueListenable: logic.isLoadingExpiring,
          builder: (context, isLoading, _) => isLoading
              ? const SliverShimmerProductList()
              : ValueListenableBuilder<List<Product>>(
                  valueListenable: logic.expiringProducts,
                  builder: (context, products, _) =>
                      _buildProductSliverList(context, logic, products),
                ),
        );
      case 2:
        return ValueListenableBuilder<bool>(
          valueListenable: logic.isLoadingLowStock,
          builder: (context, isLoading, _) => isLoading
              ? const SliverShimmerProductList()
              : ValueListenableBuilder<List<Product>>(
                  valueListenable: logic.lowStockProducts,
                  builder: (context, products, _) =>
                      _buildProductSliverList(context, logic, products),
                ),
        );
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildProductSliverList(
      BuildContext context, ProductViewModel logic, List<Product> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(SvgAssets.noRecord, height: 120),
                const SizedBox(height: 8),
                const Text(
                  'No products available',
                  style: TextStyle(fontSize: 18, color: ColorValues.greyColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          final isExpiring = logic.productTabIndex.value == 1 &&
              product.expiryDate?.isNotEmpty == true;
          final isLowStock = logic.productTabIndex.value == 2 &&
              product.quantity != null &&
              product.minQuantity != null &&
              product.quantity! <= product.minQuantity!;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: ColorValues.whiteColor),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : const Icon(Icons.inventory, size: 50),
              title: Text(
                product.name ?? 'Unknown Product',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null)
                    Text('Category: ${product.category}'),
                  if (product.quantity != null)
                    Text('Stock: ${product.quantity}'),
                  if (isExpiring && product.expiryDate != null)
                    Text(
                      'Expires: ${product.expiryDate}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (isLowStock && product.minQuantity != null)
                    Text(
                      'Min. Quantity: ${product.minQuantity}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'details',
                    child: const Text('View Details'),
                    onTap: () => navigationService
                        .navigateToWidget(ProductDetailsView(product: product)),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: const Text('Edit'),
                    onTap: () => navigationService.navigateTo(
                      addProductViewRoute,
                      arguments: {
                        'isEditing': true,
                        'product': product,
                        'storeId': locator<CustomerService>().activeStoreId,
                        'ownerId': locator<CustomerService>().getOwnerId(),
                      },
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                    onTap: () => logic.deleteProduct(context, product),
                  ),
                  if (isLowStock)
                    PopupMenuItem(
                      value: 'restock',
                      child: const Text('Restock'),
                      onTap: () => _showRestockDialog(context, product),
                    ),
                ],
              ),
              onTap: () => navigationService
                  .navigateToWidget(ProductDetailsView(product: product)),
            ),
          );
        },
        childCount: products.length,
      ),
    );
  }

  void _showRestockDialog(BuildContext context, Product product) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restock Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter additional quantity for "${product.name}".'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorValues.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final qty = int.tryParse(controller.text);
              if (qty != null && qty > 0) {
                Navigator.pop(context);
                await locator<ProductViewModel>()
                    .supplyProduct(context, product, qty);
              } else {
                showCustomToast('Please enter a valid quantity.');
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }

  Widget buildInventoryWidget(
    BuildContext context, {
    required double totalCost,
    required double totalSellingPrice,
    required int totalStock,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              title: 'Total Cost',
              value: '₦${totalCost.toStringAsFixed(2)}',
            ),
            const VerticalDivider(color: Colors.grey, thickness: 1),
            _buildSummaryItem(
              title: 'Selling Price',
              value: '₦${totalSellingPrice.toStringAsFixed(2)}',
            ),
            const VerticalDivider(color: Colors.grey, thickness: 1),
            _buildSummaryItem(
              title: 'Total Stock',
              value: totalStock.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({required String title, required String value}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            title,
            align: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          AppText(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SliverShimmerProductList extends StatelessWidget {
  const SliverShimmerProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(radius: 25, backgroundColor: Colors.white),
              title: SizedBox(
                height: 16,
                width: 150,
                child: ColoredBox(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                    width: 100,
                    child: ColoredBox(color: Colors.white),
                  ),
                  SizedBox(
                    height: 8,
                    width: 80,
                    child: ColoredBox(color: Colors.white),
                  ),
                ],
              ),
              trailing: Icon(Icons.more_vert),
            ),
          ),
        ),
        childCount: 8,
      ),
    );
  }
}
