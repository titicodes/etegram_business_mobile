// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/strings.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
// import 'package:etegram_business/module/home/vm/home_vm.dart';
// import 'package:etegram_business/module/product/view/search_view.dart';
// import 'package:etegram_business/module/product/vm/product_viewmodel.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../constants/colors.dart';
// import '../../../routes/routes.dart';
//
// class HomeView extends StatelessWidget {
//   const HomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     var logic = locator<ProductViewModel>();
//     return BaseView<HomeViewModel>(
//       onModelReady: (model) => model.init(),
//       builder: (_, model, child) => Scaffold(
//         key: model.scaffoldKey,
//         backgroundColor: ColorValues.backgroundColor,
//         drawer: const NavDrawer(),
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SvgPicture.asset(SvgAssets.avatar),
//                 SizedBox(width: 8.0),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     AppText(
//                       StringValues.welcome,
//                       style: bodyMedium,
//                     ),
//                     2.0.sbH,
//                     AppText(
//                       model.getFullName() ?? "Anietimfon Effiong",
//                       style: normalTextStyle12,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap: () {},
//                     child: SvgPicture.asset(
//                       SvgAssets.notification,
//                       height: 30,
//                       width: 30,
//                     ),
//                   ),
//                   SizedBox(width: 8.0),
//                   InkWell(
//                     onTap: () {
//                       model.openDrawer();
//                     },
//                     child: SvgPicture.asset(
//                       SvgAssets.menu,
//                       height: 40,
//                       width: 40,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 24.0.sbH,
//                 SvgPicture.asset(SvgAssets.adsBanner),
//                 30.0.sbH,
//                 InkWell(
//                   onTap: () {
//                     navigationService.navigateToWidget(SearchProductView());
//                   },
//                   child: Container(
//                     height: 40,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: ColorValues.whiteColor),
//                     child: AppText(
//                       StringValues.tapToChech,
//                       style: labelMedium,
//                     ),
//                   ),
//                 ),
//                 30.0.sbH,
//                 GestureDetector(
//                     onTap: () {
//                       navigationService.navigateTo(addProductScannerRoute);
//                     },
//                     child: SvgPicture.asset(SvgAssets.scan)),
//                 20.0.sbH,
//                 Center(
//                     child: AppText(
//                   StringValues.or,
//                   style: normalTextStyle12,
//                 )),
//                 20.0.sbH,
//                 Container(
//                   height: 135,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: Color(0xffFEEAFA)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       16.0.sbH,
//                       SvgPicture.asset(SvgAssets.newSupplier),
//                       10.0.sbH,
//                       AppText(
//                         StringValues.howItWorks,
//                         style: bodyMedium,
//                       ),
//                       6.0.sbH,
//                       AppText(
//                         StringValues.howToUseApp,
//                         style: normalTextStyle12,
//                       ),
//                       20.0.sbH,
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/product/view/search_view.dart';
import 'package:etegram_business/module/product/vm/product_viewmodel.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../../constants/colors.dart';
import '../../../routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    var logic = locator<ProductViewModel>();
    return BaseView<HomeViewModel>(
      onModelReady: (model) {
        model.context = context; // Set context for dialog
        model.init();
      },
      builder: (_, model, child) => Scaffold(
        key: model.scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        drawer: const NavDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: model.profileImageUrl,
                      builder: (context, imageUrl, _) => SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CircleAvatar(
                            backgroundColor: ColorValues.greyColor,
                            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? SvgPicture.asset(
                              SvgAssets.avatar,
                              height: 30,
                              width: 30,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => model.showImageSourceDialog(context),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ColorValues.primaryColor,
                          ),
                          child: const Icon(
                            LineAwesomeIcons.camera_retro_solid,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      StringValues.welcome,
                      style: bodyMedium,
                    ),
                    const SizedBox(height: 2.0),
                    AppText(
                      model.getFullName().isNotEmpty ? model.getFullName() : "Anietimfon Effiong",
                      style: normalTextStyle12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: SvgPicture.asset(
                      SvgAssets.notification,
                      height: 30,
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  InkWell(
                    onTap: () => model.openDrawer(),
                    child: SvgPicture.asset(
                      SvgAssets.menu,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                AppText(
                  'Supported formats: JPEG, PNG, GIF, WebP, BMP (max 5MB)',
                  style: normalTextStyle12.copyWith(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 10.0),
                SvgPicture.asset(SvgAssets.adsBanner),
                const SizedBox(height: 30.0),
                InkWell(
                  onTap: () {
                    navigationService.navigateToWidget(const SearchProductView());
                  },
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: ColorValues.whiteColor,
                    ),
                    child: AppText(
                      StringValues.tapToChech,
                      style: labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                GestureDetector(
                  onTap: () {
                    navigationService.navigateTo(addProductScannerRoute);
                  },
                  child: SvgPicture.asset(SvgAssets.scan),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: AppText(
                    StringValues.or,
                    style: normalTextStyle12,
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  height: 135,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xffFEEAFA),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16.0),
                      SvgPicture.asset(SvgAssets.newSupplier),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          navigationService.navigateTo(howItWorksRoute);
                        },
                        child: AppText(
                          StringValues.howItWorks,
                          style: bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      AppText(
                        StringValues.howToUseApp,
                        style: normalTextStyle12,
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}