import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../app_widget/custom_appbar.dart';
import '../../../constants/strings.dart';
import '../view_model/supplier_list_vm.dart';
import 'new_supplier.dart'; // Import the ViewModel

class ListOfSuppliers extends StatefulWidget {
  const ListOfSuppliers({super.key});

  @override
  State<ListOfSuppliers> createState() => _ListOfSuppliersState();
}

class _ListOfSuppliersState extends State<ListOfSuppliers> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<SupplierListViewModel>().loadSuppliers();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BaseView<SupplierListViewModel>(
      onModelReady: (model) => model.loadSuppliers(),
      builder: (context, logic, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: StringValues.suppliers,
            onBackPressed: () {},
            showMenuIcon: true,
            onMenuPressed: () {
              // Handle menu action
            },
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
                    AppText("Total Suppliers: ${logic.suppliers.length}",
                        style: normalTextStyle12),
                    10.0.sbH,
                    AppTextField(
                      hintText: StringValues.tapToSeeSupplier,
                      onChanged: logic.searchSuppliers,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: logic.isLoading
                    ? Center(child: SpinKitFadingCircle(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ))
                    : logic.suppliers.isEmpty
                        ? Center(child: SvgPicture.asset(SvgAssets.noRecord))
                        : ListView.builder(
                            itemCount: logic.suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = logic.suppliers[index];
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
