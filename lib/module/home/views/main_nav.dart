import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/main_nav_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNav extends StatelessWidget {
  const MainNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<MainNavViewModel>(
      onModelReady: (model) => model.init(model.selectedPage),
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: model.pages.elementAt(model.selectedPage),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: model.selectedPage,
          backgroundColor: ColorValues.whiteColor,
          elevation: 0,
          iconSize: 40,
          mouseCursor: SystemMouseCursors.grab,
          selectedFontSize: 16,
          selectedIconTheme:
              IconThemeData(color: ColorValues.primaryDarkColor, size: 40),
          selectedItemColor: ColorValues.primaryDarkColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedIconTheme: IconThemeData(
            color: ColorValues.appTextColor,
          ),
          unselectedItemColor: ColorValues.appTextColor,
          onTap: model.onNavigationItem,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(SvgAssets.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(SvgAssets.chart),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(SvgAssets.product),
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(SvgAssets.truck),
              label: 'Supply',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(SvgAssets.profile),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
