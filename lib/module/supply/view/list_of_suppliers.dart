import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/module/supply/view/widget/search_supplier_view.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../view_model/supplier_list_vm.dart';
import 'new_supplier.dart';

class ListOfSuppliers extends StatelessWidget {
  const ListOfSuppliers({super.key});

  @override
  Widget build(BuildContext context) {
    var homeVm = locator<HomeViewModel>();

    return BaseView<SupplierListViewModel>(
      onModelReady: (model) => model.loadSuppliers(),
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: ColorValues.backgroundColor,
          key: homeVm.scaffoldKey,
          drawer: NavDrawer(),
          appBar: CustomAppBar(
            title: StringValues.suppliers,
            onBackPressed: () => homeVm.openDrawer(),
            showMenuIcon: true,
            onMenuPressed: () => navigationService.goBack(),
            showNotificationIcon: false,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewSupplierView(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AppText(
                      StringValues.suppliers,
                      style: headerTextStyle.copyWith(
                          color: ColorValues.appTextColor),
                    ),
                    10.0.sbH,
                    AppText(
                      "Total Suppliers: ${logic.filteredSuppliers.length}",
                      style: normalTextStyle12,
                    ),
                    10.0.sbH,
                    AppTextField(
                      hint: StringValues.tapToSeeSupplier,
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchSupplierScreen(),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
              Expanded(
                child: logic.isLoading.value
                    ? Center(
                        child: SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: index.isEven ? Colors.red : Colors.green,
                              ),
                            );
                          },
                        ),
                      )
                    : logic.filteredSuppliers.isEmpty
                        ? Center(child: SvgPicture.asset(SvgAssets.noRecord))
                        : ListView.builder(
                            itemCount: logic.filteredSuppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = logic.filteredSuppliers[index];
                              return ListTile(
                                title: Text(
                                  supplier.data?.businessName ?? "",
                                  style: normalTextStyle,
                                ),
                                subtitle: Text(
                                  supplier.data?.email ?? "",
                                  style: normalTextStyle12,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewSupplierView(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
