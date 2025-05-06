import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import '../vm/product_viewmodel.dart'; // Import your ViewModel
import 'add_product.dart';

class SearchProductView extends StatelessWidget {
  const SearchProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<PRoductViewModel>(
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: "Search Products",
          onBackPressed: () {
            navigationService.goBack();
          },
          showNotificationIcon: false,
          showMenuIcon: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              30.0.sbH,
              AppTextField(
                controller: model.searchController,
                hint: 'Search for a product',
                prefix: const Icon(Icons.search),
                onChanged: model.searchProduct,
              ),
              20.0.sbH,
              Expanded(
                child: model.isLoading.value
                    ? Center(
                        child: SpinKitChasingDots(
                        color: Colors.white,
                        size: 50.0,
                      ))
                    : (model.products.isNotEmpty
                        ? ListView.builder(
                            itemCount: model.products.length,
                            itemBuilder: (context, index) {
                              final product = model.products[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddProductView(
                                        product: product,
                                        isEditing: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText(
                                              product.name ?? 'Unknown Product',
                                              style: subHeaderTextStyle,
                                            ),
                                            AppText(
                                              "x${product.quantity.toString()}",
                                              style: bodyLarge,
                                            ),
                                          ],
                                        ),
                                        6.0.sbH,
                                        AppText(
                                          "Size:${product.size.toString()}ml",
                                          style: normalTextStyle12,
                                        ),
                                        10.0.sbH,
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (product.unitPrice != null)
                                              Text(
                                                NumberFormat.currency(
                                                        symbol: 'N',
                                                        decimalDigits: 2)
                                                    .format(product.unitPrice),
                                              ),
                                            if (product.unitPrice != null)
                                              Text(
                                                NumberFormat.currency(
                                                        symbol: 'N',
                                                        decimalDigits: 2)
                                                    .format(product.unitPrice),
                                              ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(child: SvgPicture.asset(SvgAssets.noRecord))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
