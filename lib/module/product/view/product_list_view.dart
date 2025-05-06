import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../app_widget/custom_sliver_appbar.dart';
import '../../../constants/assets.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../core/model/product_model.dart';
import '../vm/product_vm.dart';

class AddProductListView extends StatefulWidget {
  const AddProductListView({super.key});

  @override
  State<AddProductListView> createState() => _AddProductListViewState();
}

class _AddProductListViewState extends State<AddProductListView> {
  @override
  Widget build(BuildContext context) {
    var model = locator<HomeViewModel>();
    return BaseView<ProductViewModel>(
      onModelReady: (vm) => vm.initialize(),
      builder: (_, logic, child) => Scaffold(
        key: model.scaffoldKey,
        drawer: NavDrawer(),
        backgroundColor: ColorValues.backgroundColor,
        body: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              title: StringValues.productList,
              onBackPressed: () {
                navigationService.goBack();
              },
              showMenuIcon: true,
              onMenuPressed: () {
                model.openDrawer();
              },
              showNotificationIcon: false,
              logoAsset: SvgAssets.appLogo,
              showLogo: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.0.sbH,
                    ValueListenableBuilder<double>(
                      valueListenable: logic.totalCost,
                      builder: (context, totalCostValue, child) {
                        return ValueListenableBuilder<double>(
                          valueListenable: logic.totalSellingPrice,
                          builder: (context, totalPriceValue, child) {
                            return ValueListenableBuilder<int>(
                              valueListenable: logic.totalStock,
                              builder: (context, totalStockValue, child) {
                                return buildInventoryWidget(
                                  context,
                                  totalCost: totalCostValue,
                                  totalSellingPrice: totalPriceValue,
                                  totalStock: totalStockValue,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    30.0.sbH,
                    AppTextField(
                      prefix: const Icon(
                        Icons.search,
                        color: ColorValues.greyColor,
                      ),
                      hint: StringValues.tapToChech,
                      onTap: () {
                        navigationService
                            .navigateToWidget(const SearchProductView());
                      },
                    ),
                    20.0.sbH,
                    // Use FlutterToggleTab for tabs
                    ValueListenableBuilder<int>(
                      valueListenable: logic.productTabIndex,
                      builder: (context, selectedIndex, child) {
                        return FlutterToggleTab(
                          width: 90,
                          borderRadius: 30,
                          height: 40,
                          selectedIndex: selectedIndex,
                          selectedBackgroundColors: const [
                            ColorValues.primaryColor,
                            Colors.blueAccent,
                          ],
                          selectedTextStyle: normalTextStyle.copyWith(
                              color: ColorValues.whiteColor),
                          unSelectedTextStyle: normalTextStyle,
                          dataTabs: logic.productTabOptions,
                          selectedLabelIndex: (index) {
                            logic.productTabIndex.value = index;
                          },
                          isScroll: false,
                          isInnerShadowEnable: false,
                          isShadowEnable: false,
                        );
                      },
                    ),
                    30.0.sbH,
                    // Display content based on selected tab index
                    ValueListenableBuilder<int>(
                      valueListenable: logic.productTabIndex,
                      builder: (context, index, child) {
                        if (logic.isLoading.value && index == 0) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (logic.isLoadingExpiring && index == 1) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (logic.isLoadingLowStock && index == 2) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return _buildProductTabView(logic, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each tab view (All, Expiring, Low Stock)
  Widget _buildProductTabView(ProductViewModel logic, int index) {
    switch (index) {
      case 0:
        return _buildProductListView(logic, logic.allProducts);
      case 1:
        return _buildProductListView(logic, logic.expiringProducts);
      case 2:
        return _buildProductListView(logic, logic.lowStockProducts);
      default:
        return Container();
    }
  }

  // Helper method to build product list view
  Widget _buildProductListView(ProductViewModel logic, List<Product> products) {
    if (products.isEmpty) {
      return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(SvgAssets.noRecord),
              8.0.sbH,
              const Text(
                'No products available',
                style: TextStyle(fontSize: 18, color: ColorValues.greyColor),
              ),
            ],
          ));
    }

    return ListView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? "Unknown Product",
                  style: normalTextStyle12.copyWith(fontSize: 16),
                ),
                8.0.sbH,
                Text('Category: ${product.category ?? "No category"}'),
                Text('Code: ${product.code ?? "N/A"}'),
                Text('Price: ${product.price ?? "N/A"}'),
                Text('Stock: ${product.stock ?? "N/A"}'),
                if (logic.productTabIndex.value == 1 &&
                    product.expiryDate != null &&
                    product.expiryDate!.isNotEmpty)
                  Text('Expiry: ${product.expiryDate}'),
                if (logic.productTabIndex.value == 2)
                  Text('Min. Quantity: ${product.minQuantity ?? "N/A"}'),
                // Add more product details as needed
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInventoryWidget(BuildContext context,
      {double totalCost = 0.0,
        double totalSellingPrice = 0.0,
        int totalStock = 0}) {
    return Container(
      height: 100,
      width: width(context),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: ColorValues.whiteColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  StringValues.totalProductCost,
                  align: TextAlign.center,
                  style: normalTextStyle,
                ),
                6.0.sbH,
                AppText(
                  '$totalCost',
                  style: normalTextStyle,
                ),
              ],
            ),
          ),
          const VerticalDivider(
              color: ColorValues.backgroundColor, thickness: 2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  StringValues.totalSellingPrice,
                  align: TextAlign.center,
                  style: normalTextStyle,
                ),
                6.0.sbH,
                AppText(
                  '$totalSellingPrice',
                  style: normalTextStyle,
                ),
              ],
            ),
          ),
          const VerticalDivider(
              color: ColorValues.backgroundColor, thickness: 2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  StringValues.totalStock,
                  align: TextAlign.center,
                  style: normalTextStyle,
                ),
                6.0.sbH,
                AppText(
                  '$totalStock',
                  style: normalTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}