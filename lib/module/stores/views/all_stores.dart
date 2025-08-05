import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/stores/views/widgets/store_card.dart';
import 'package:etegram_business/module/stores/vm/stores_vm.dart';
import 'package:etegram_business/service/local/drawer_service.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../app_widget/app_text.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../../../routes/routes.dart';

class AllStores extends StatelessWidget {
  const AllStores({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerService = locator<DrawerService>();

    return BaseView<StoresViewModel>(
      onModelReady: (model) {
        model.onInit();
        drawerService.setScaffoldKey(scaffoldKey);
      },
      builder: (_, model, child) => Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        drawer: NavDrawer(),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: model.fetchStores,
              child: CustomScrollView(
                slivers: [
                  CustomSliverAppBar(
                    title: "All Stores",
                    onBackPressed: () => navigationService.goBack(),
                    showMenuIcon: true,
                    onMenuPressed: () {
                      print('OtherView: Opening drawer');
                      drawerService.openDrawer(); // Use DrawerService
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
                            "Your Stores",
                            style: subHeaderTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: model.isLoading,
                    builder: (context, isLoading, child) {
                      if (isLoading) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: SpinKitWave(
                              color: ColorValues.primaryColor,
                              size: 50.0,
                            ),
                          ),
                        );
                      }
                      if (model.allStores == null || model.allStores!.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: 16.0.padA,
                            child: AppText(
                              "No stores found. Create a store to get started!",
                              style: normalTextStyle,
                              align: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.all(8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final store = model.allStores![index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: StoreCard(store: store),
                              );
                            },
                            childCount: model.allStores!.length,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (model.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: SpinKitWave(
                    color: ColorValues.primaryColor,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model.setEditing(null); // Clear editing state for new store
            navigationService
                .navigateTo(createStoreRoute); // Navigate to create store view
          },
          backgroundColor: ColorValues.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
