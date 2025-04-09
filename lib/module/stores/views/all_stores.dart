import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/stores/views/widgets/store_card.dart';
import 'package:etegram_business/module/stores/vm/stores_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/app_text.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';

class AllStores extends StatelessWidget {
  const AllStores({super.key});
  @override
  Widget build(BuildContext context) {
    var logic = locator<HomeViewModel>();
    return BaseView<StoresViewModel>(
      builder: (_, model, child) => Scaffold(
          key: logic.scaffoldKey,
          backgroundColor: ColorValues.backgroundColor,
          drawer: NavDrawer(),
          body: CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                title: "All Stores",
                onBackPressed: () {
                  navigationService.goBack();
                },
                showMenuIcon: true,
                onMenuPressed: () {
                  logic.openDrawer();
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: 16.0.padA,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.0.sbH,
                      AppText(
                        StringValues.totalCustomers,
                        style: subHeaderTextStyle,
                      )
                    ],
                  ),
                ),
              ),
              SliverPadding(
                // Add padding around the list
                padding: const EdgeInsets.all(8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Handle potential null list or null items gracefully
                      final stores = model.allStores?[index];
                      if (stores == null) {
                        // Return a placeholder or an empty container if an item is unexpectedly null
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        // Add padding between cards if needed
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: StoreCard(store: stores),
                      );
                    },
                    childCount: model.allStores?.length ??
                        0, // Handle null list for count
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
