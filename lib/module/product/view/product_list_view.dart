import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/module/product/vm/product_viewmodel.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../app_widget/custom_sliver_appbar.dart';
import '../../../constants/assets.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../core/model/product_model.dart';
import '../vm/product_vm.dart';

class AddProductListView extends StatelessWidget {
  const AddProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    var model = locator<HomeViewModel>();
    return BaseView<ProductViewModel>(
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.0.sbH,
                    buildInventoryWidget(context),
                    30.0.sbH,
                    AppTextField(
                      prefix: Icon(
                        Icons.search,
                        color: ColorValues.greyColor,
                      ),
                      hint: StringValues.tapToChech,
                      onTap: () {
                        navigationService.navigateToWidget(SearchProductView());
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
                          selectedTextStyle: normalTextStyle.copyWith(color: ColorValues.whiteColor),
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
                    _buildProductTabView(logic),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper method to build each tab view (All, Expiring, Low Stock)
  Widget _buildProductTabView(ProductViewModel logic) {
    switch (logic.productTabIndex.value) {
      case 0:
      // All Products
        return _buildProductListView(logic.allProducts);
      case 1:
      // Expiring Products
        return _buildProductListView(logic.expiringProducts);
      case 2:
      // Low Stock Products
        return _buildProductListView(logic.lowStockProducts);
      default:
        return Container();
    }
  }

  // Helper method to build product list view
  Widget _buildProductListView(List<Product> products) {
    // Check if products is null or empty
    if (products == null || products.isEmpty) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(SvgAssets.noRecord),
            8.0.sbH,
            Text(
              'No products available',
              style: TextStyle(fontSize: 18, color: ColorValues.greyColor),
            ),
          ],
        )
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name ?? "Unknown Product"),
          subtitle: Text('Category: ${product.category ?? "No category"}'),
        );
      },
    );
  }


  Container buildInventoryWidget(BuildContext context) {
    return Container(
      height: 100,
      width: width(context),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: ColorValues.whiteColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              AppText(
                StringValues.totalProductCost,
                align: TextAlign.center,
                style: normalTextStyle,
              ),
              6.0.sbH,
              AppText(
                StringValues.totalAmount,
                style: normalTextStyle,
              ),
            ],
          ),
          Container(
            width: 2,
            height: 100,
            color: ColorValues.backgroundColor,
          ),
          Column(
            children: [
              AppText(
                StringValues.totalProductCost,
                style: normalTextStyle,
              ),
              6.0.sbH,
              AppText(
                StringValues.totalAmount,
                style: normalTextStyle,
              ),
            ],
          ),
          Container(
            width: 2, // Width of the line
            height: 100, // Height of the line (adjust as needed)
            color: ColorValues.backgroundColor, // Color of the line
          ),
          Column(
            children: [
              AppText(
                StringValues.totalProductCost,
                style: normalTextStyle,
              ),
              6.0.sbH,
              AppText(
                StringValues.totalAmount,
                style: normalTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
