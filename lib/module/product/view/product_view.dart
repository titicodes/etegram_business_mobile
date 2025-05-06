import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/product/view/add_product.dart';
import 'package:etegram_business/module/product/view/move_products.dart';
import 'package:etegram_business/module/product/view/product_list_view.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/module/product/view/tabs/manual_add_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:etegram_business/constants/assets.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/reuseable.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../home/vm/home_vm.dart';
import '../vm/product_viewmodel.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEditing = false;
    var logic = locator<HomeViewModel>();
    return BaseView<PRoductViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        key: logic.scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: 'Products',
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: true,
          onMenuPressed: () {
            logic.openDrawer();
          },
        ),
        drawer: NavDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                30.0.sbH,
                // Replace AppTextField with an InkWell for navigation
                AppTextField(
                  controller: model.searchController,
                  hint: 'Search for a product',
                  prefix: const Icon(Icons.search),
                  onTap: () {
                    navigationService.navigateToWidget(SearchProductView());
                  },
                ),
                40.0.sbH,
                InkWell(
                  onTap: () {
                    model.startBarcodeScan(context); // Open the barcode scanner
                  },
                  child: SvgPicture.asset(SvgAssets.scan),
                ),

                30.0.sbH,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return GestureDetector(
                      onTap: () {
                        switch (index) {
                          case 0:
                            navigationService.navigateToWidget(
                                ManualAddProductScreen());
                            break;
                          case 1:
                            navigationService
                                .navigateToWidget(AddProductListView());
                            break;
                          case 2:
                            navigationService.navigateToWidget(MoveProducts());
                            break;
                        }
                      },
                      child: Container(
                        width: 90,
                        height: 100,
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(8.0),
                        color: model.containerColor[index],
                        child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            SvgPicture.asset(
                              model.images[index],
                              height: 30,
                              width: 30,
                            ),
                            AppText(
                              model.productOperations[index],
                              style: normalTextStyle.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                              align: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
