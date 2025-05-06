import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/module/product/vm/product_vm.dart';
import 'package:etegram_business/module/supply/view_model/supplier_list_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app_widget/input_fields.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../locator.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../home/vm/home_vm.dart';
import '../../product/view/add_product.dart';
import '../../product/vm/product_viewmodel.dart';

class NewSupplyView extends StatelessWidget {
  const NewSupplyView({super.key});

  @override
  Widget build(BuildContext context) {
    var homeVm = locator<HomeViewModel>();
    var model = locator<PRoductViewModel>();
    return BaseView<SupplierListViewModel>(
      builder: (_, logic, child) => Scaffold(
          key: homeVm.scaffoldKey,
          drawer: NavDrawer(),
          backgroundColor: ColorValues.backgroundColor,
          body: CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                title: StringValues.newSupply,
                onBackPressed: () {
                  navigationService.goBack();
                },
                showMenuIcon: true,
                onMenuPressed: () {
                  homeVm.openDrawer();
                },
                showLogo: true,
                logoAsset: SvgAssets.appLogo,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: 16.0.padA,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      40.0.sbH,
                      AppTextField(
                        controller: logic.searchController,
                        hint: StringValues.tapToSeeSupplier,
                        onTap: () {
                          navigationService
                              .navigateToWidget(SearchProductView());
                        },
                      ),
                      const SizedBox(height: 20),
                      // if (logic.isSearching)
                      //   const CircularProgressIndicator()
                      // else if (logic.searchedProducts.isNotEmpty)
                      //   Expanded(
                      //     child: ListView.builder(
                      //       itemCount: logic.searchedProducts.length,
                      //       itemBuilder: (context, index) {
                      //         final product = logic.searchedProducts[index];
                      //         return ListTile(
                      //           title: Text(userService.product.name ?? ""),
                      //           subtitle: Text(product.code ?? ''),
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => AddProductView(
                      //                   product: product,
                      //                   isEditing: true,
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   )
                      // else if (logic.searchController.text.isNotEmpty)
                      //     const Expanded(
                      //       child: Center(
                      //         child: Text("No products found."),
                      //       ),
                      //     ),
                      const SizedBox(height: 20),
                      const Text("or"),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          model.startBarcodeScan(
                              context); // Open the barcode scanner
                        },
                        child: SvgPicture.asset(SvgAssets.scan),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
