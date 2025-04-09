import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/product/view/tabs/received_tab.dart';
import 'package:etegram_business/module/product/view/tabs/sent_tab.dart';
import 'package:etegram_business/module/product/vm/product_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app_widget/custom_appbar.dart';
import '../../../constants/strings.dart';
import '../../../core/model/product_model.dart';

class MoveProducts extends StatelessWidget {
  const MoveProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      builder: (_, controller, child) => Scaffold(
        appBar: CustomAppBar(
          title: StringValues.newSupplier,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
          showMenuIcon: true,
          onMenuPressed: () {
            // Handle menu action
          },
          showNotificationIcon: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            30.0.sbH,
            AppText(StringValues.moveProducts, style: headerTextStyle),
            20.0.sbH,

            // Search Bar
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: TextField(
            //     onChanged: (value) => controller.searchProducts(value),
            //     decoration: InputDecoration(
            //       labelText: 'Search for a product',
            //       prefixIcon: Icon(Icons.search),
            //       border: OutlineInputBorder(),
            //     ),
            //   ),
            // ),

            // Scan Button
            ElevatedButton(
              onPressed: () => controller.scanBarcode(context),
              child: Text('Scan Barcode'),
            ),

            // Tab Bar for Product Status
            20.0.sbH,
            ValueListenableBuilder<int>(
              valueListenable: controller.tabIndex,
              builder: (context, selectedIndex, child) {
                return FlutterToggleTab(
                  width: 90,
                  borderRadius: 30,
                  height: 50,
                  selectedIndex: selectedIndex,
                  selectedBackgroundColors: const [
                    ColorValues.primaryColor,
                    Colors.blueAccent,
                  ],
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  unSelectedTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dataTabs: controller.tabOptions,
                  selectedLabelIndex: (index) {
                    controller.tabIndex.value = index; // Update the tab index
                  },
                  isScroll: false,
                );
              },
            ),

            20.0.sbH,

            // Reactive Page Switching
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: controller.tabIndex,
                builder: (context, selectedIndex, child) {
                  return IndexedStack(
                    index: selectedIndex,
                    children: [
                      _buildProductList(controller.products),
                      _buildProductList(controller.expiringProducts),
                      _buildProductList(controller.lowStockProducts),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name ?? "Aqa Finna"),
          subtitle: Text('Quantity: ${product.quantity}'),
          onTap: () {
            // Handle product tap, e.g., navigate to product details
          },
        );
      },
    );
  }
}
