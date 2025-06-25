import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
// import 'package:etegram_business/module/sales/vm/sales_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app_widget/app_text.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../vm/new_sales_vm.dart';

class SAles extends StatelessWidget {
  const SAles({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEditing = false;
    var homeModel = locator<HomeViewModel>();
   // var model = locator<ProductViewModel>();
    return BaseView<SaleViewModel>(
      builder: (_, logic, child) => Scaffold(
        key: homeModel.scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.sales,
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: true,
          onMenuPressed: () {
            homeModel.openDrawer();
          },
        ),
        drawer: NavDrawer(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  100.0.sbH,

                  Container(
                    width: width(context),
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorValues.whiteColor),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tap here to search for or add products",
                        hintStyle: normalTextStyle,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      // onSubmitted: (query) async {
                      //   await logic.searchProduct(query);
                      // },
                      onTap: (){
                        navigationService.navigateToWidget(SearchProductView());
                      },
                    ),
                  ),
                  60.0.sbH,
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "or",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  40.0.sbH,
                  // InkWell(
                  //   onTap: () {
                  //     logic.startBarcodeScan(context);
                  //   },
                  //   child: SvgPicture.asset(SvgAssets.scan),
                  // ),
                  20.0.sbH,
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: List.generate(3, (index) {
                  //     return GestureDetector(
                  //       onTap: () {
                  //         switch (index) {
                  //           case 0:
                  //             navigationService.navigateToWidget(
                  //                 AddProductView(isEditing: isEditing));
                  //             break;
                  //           case 1:
                  //             navigationService
                  //                 .navigateToWidget(AddProductListView());
                  //             break;
                  //           case 2:
                  //             navigationService.navigateToWidget(MoveProducts());
                  //             break;
                  //         }
                  //       },
                  //       child: Container(
                  //           width: 100,
                  //           height: 100,
                  //           margin: EdgeInsets.all(4.0),
                  //           color: model.containerColor[index],
                  //           child: Column(
                  //             children: [
                  //               8.0.sbH,
                  //               SvgPicture.asset(
                  //                 model.images[index],
                  //                 height: 30,
                  //                 width: 30,
                  //               ),
                  //               10.0.sbH,
                  //               AppText(
                  //                 model.productOperations[index],
                  //                 style: normalTextStyle,
                  //                 align: TextAlign.center,
                  //               )
                  //             ],
                  //           )),
                  //     );
                  //   }),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
