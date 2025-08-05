// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
// import 'package:etegram_business/module/home/vm/main_nav_vm.dart';
// import 'package:etegram_business/module/home/views/home_view.dart';
// import 'package:etegram_business/module/sales/view/new_sales_view.dart';
// import 'package:etegram_business/module/product/view/product_view.dart';
// import 'package:etegram_business/module/account/views/account_view.dart';
//
// class MainNav extends StatelessWidget {
//   const MainNav({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<MainNavViewModel>(
//       onModelReady: (model) {
//         print('MainNav: Model ready, instance: ${model.hashCode}');
//         model.init(model.selectedPage);
//       },
//       builder: (context, model, child) => WillPopScope(
//         onWillPop: () async {
//           if (model.selectedPage != 0) {
//             model.onNavigationItem(0);
//             return false;
//           }
//           return true;
//         },
//         child: Scaffold(
//           backgroundColor: ColorValues.backgroundColor,
//           body: model.pages.elementAt(model.selectedPage),
//           bottomNavigationBar: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             currentIndex: model.selectedPage,
//             backgroundColor: ColorValues.whiteColor,
//             elevation: 0,
//             iconSize: 40,
//             mouseCursor: SystemMouseCursors.grab,
//             selectedFontSize: 16,
//             selectedIconTheme: const IconThemeData(
//               color: ColorValues.primaryDarkColor,
//               size: 30,
//             ),
//             selectedItemColor: ColorValues.primaryDarkColor,
//             selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
//             unselectedIconTheme: const IconThemeData(
//               color: ColorValues.appTextColor,
//             ),
//             unselectedItemColor: ColorValues.appTextColor,
//             onTap: model.onNavigationItem,
//             items:  <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: SvgPicture.asset(
//                   SvgAssets.home,
//                   color: ColorValues.appTextColor,
//                 ),
//                 activeIcon: SvgPicture.asset(
//                   SvgAssets.home,
//                   color: ColorValues.primaryDarkColor,
//                 ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: SvgPicture.asset(
//                   SvgAssets.chart,
//                   color: ColorValues.appTextColor,
//                 ),
//                 activeIcon: SvgPicture.asset(
//                   SvgAssets.chart,
//                   color: ColorValues.primaryDarkColor,
//                 ),
//                 label: 'Sales',
//               ),
//               BottomNavigationBarItem(
//                 icon: SvgPicture.asset(
//                   SvgAssets.product,
//                   color: ColorValues.appTextColor,
//                 ),
//                 activeIcon: SvgPicture.asset(
//                   SvgAssets.product,
//                   color: ColorValues.primaryDarkColor,
//                 ),
//                 label: 'Product',
//               ),
//               BottomNavigationBarItem(
//                 icon: SvgPicture.asset(
//                   SvgAssets.profile,
//                   color: ColorValues.appTextColor,
//                 ),
//                 activeIcon: SvgPicture.asset(
//                   SvgAssets.profile,
//                   color: ColorValues.primaryDarkColor,
//                 ),
//                 label: 'Account',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/views/home_view.dart';
import 'package:etegram_business/module/sales/view/new_sales_view.dart';
import 'package:etegram_business/module/product/view/product_view.dart';
import 'package:etegram_business/module/account/views/account_view.dart';
import 'package:etegram_business/module/home/vm/main_nav_vm.dart';

class MainNav extends StatelessWidget {
  const MainNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<MainNavViewModel>(
      onModelReady: (model) {
        print('MainNav: Model ready, instance: ${model.hashCode}');
        model.init(model.selectedPage);
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          if (model.selectedPage != 0) {
            print('MainNav: Switching to Home tab');
            model.onNavigationItem(0);
            return false;
          }
          print('MainNav: Allowing pop to exit app');
          return true;
        },
        child: Scaffold(
          backgroundColor: ColorValues.backgroundColor,
          body: model.pages.elementAt(model.selectedPage),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: model.selectedPage,
            backgroundColor: ColorValues.whiteColor,
            elevation: 0,
            iconSize: 40,
            mouseCursor: SystemMouseCursors.grab,
            selectedFontSize: 16,
            selectedIconTheme: const IconThemeData(
              color: ColorValues.primaryDarkColor,
              size: 30,
            ),
            selectedItemColor: ColorValues.primaryDarkColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            unselectedIconTheme: const IconThemeData(
              color: ColorValues.appTextColor,
            ),
            unselectedItemColor: ColorValues.appTextColor,
            onTap: (index) {
              print('MainNav: Navigation item tapped: $index');
              model.onNavigationItem(index);
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  SvgAssets.home,
                  color: ColorValues.appTextColor,
                ),
                activeIcon: SvgPicture.asset(
                  SvgAssets.home,
                  color: ColorValues.primaryDarkColor,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  SvgAssets.chart,
                  color: ColorValues.appTextColor,
                ),
                activeIcon: SvgPicture.asset(
                  SvgAssets.chart,
                  color: ColorValues.primaryDarkColor,
                ),
                label: 'Sales',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  SvgAssets.product,
                  color: ColorValues.appTextColor,
                ),
                activeIcon: SvgPicture.asset(
                  SvgAssets.product,
                  color: ColorValues.primaryDarkColor,
                ),
                label: 'Product',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  SvgAssets.profile,
                  color: ColorValues.appTextColor,
                ),
                activeIcon: SvgPicture.asset(
                  SvgAssets.profile,
                  color: ColorValues.primaryDarkColor,
                ),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
