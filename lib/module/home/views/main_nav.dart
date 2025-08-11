import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
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
          print(
              'MainNav: onWillPop triggered, selectedPage: ${model.selectedPage}');
          if (model.selectedPage != 0) {
            print('MainNav: Switching to Home tab');
            model.onNavigationItem(0);
            return false;
          }
          print('MainNav: Showing exit confirmation dialog');
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierDismissible: true, // Allow dismissing by tapping outside
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Exit App',
                style: TextStyle(
                  color: ColorValues.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('MainNav: Exit dialog - Cancel selected');
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorValues.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    print('MainNav: Exit dialog - Exit selected');
                    Navigator.pop(context, true);
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          print('MainNav: Exit dialog result: $shouldExit');
          return shouldExit ?? false; // Default to false if dialog is dismissed
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
