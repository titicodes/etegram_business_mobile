import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/product/view/add_product.dart';
import 'package:etegram_business/module/product/view/move_products.dart';
import 'package:etegram_business/module/product/view/product_list_view.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:etegram_business/constants/assets.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/reuseable.dart';
import '../../../utils/snack_message.dart';
import '../../home/drawer/nav_drawer.dart';
import '../../home/vm/home_vm.dart';
import '../vm/product_viewmodel.dart';
import 'package:etegram_business/core/model/product_model.dart';
import 'package:etegram_business/service/local/user_service.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEditing = false;
    var logic = locator<HomeViewModel>();
    return BaseView<ProductViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        key: logic.scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: 'Products',
          onBackPressed: () {
            navigationService.navigateTo(dashboardRoute);
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
                  onTap: () async {
                    print('ProductView: Navigating to addProductScannerRoute');
                    final result = await Navigator.pushNamed(context, addProductScannerRoute);
                    if (!context.mounted) return;
                    final customerService = locator<CustomerService>();
                    final storeId = await customerService.getActiveStoreId();
                    final ownerId = await customerService.getOwnerId();
                    if (storeId == null || ownerId == null) {
                      showCustomToast('No active store or owner selected.', success: false);
                      return;
                    }
                    if (result is Product) {
                      print('ProductView: Scanned product: ${result.name}');
                      await model.showDuplicateDialog(context, result);
                    } else if (result is String) {
                      print('ProductView: Scanned barcode (not found): $result');
                      Navigator.pushNamed(
                        context,
                        addProductViewRoute,
                        arguments: {
                          'scannedCode': result,
                          'isEditing': false,
                          'storeId': storeId,
                          'ownerId': ownerId,
                        },
                      );
                    }
                  },
                  child: SvgPicture.asset(SvgAssets.scan),
                ),
                30.0.sbH,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return GestureDetector(
                      onTap: () async {
                        final customerService = locator<CustomerService>();
                        final storeId = await customerService.getActiveStoreId();
                        final ownerId = await customerService.getOwnerId();
                        switch (index) {
                          case 0:
                            navigationService.navigateTo(addProductViewRoute, arguments: {
                              'isEditing': false,
                              'storeId': storeId,
                              'ownerId': ownerId,
                            });
                            break;
                          case 1:
                            navigationService.navigateToWidget(AddProductListView());
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
                        child: Column(
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