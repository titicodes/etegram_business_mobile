import 'package:etegram_business/module/customer/views/widget/customer_card.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';

import '../../../app_widget/app_button.dart';
import '../../../core/model/store_model.dart';
import '../../../routes/routes.dart';
import 'new_customer.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      onModelReady: (model) => model.initState(),
      builder: (_, model, __) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: model.stores.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText('No stores available. Please create a store.',
                        style: normalTextStyle),
                    20.h.sbH,
                    AppButton(
                      text: 'Create Store',
                      onTap: () =>
                          navigationService.navigateTo(createStoreRoute),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  CustomSliverAppBar(
                    title: StringValues.customer,
                    onBackPressed: navigationService.goBack,
                    showMenuIcon: false,
                    showNotificationIcon: false,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            '${StringValues.totalCustomers}: ${model.allCustomers?.length ?? 0}',
                            style: subHeaderTextStyle,
                          ),
                          10.h.sbH,
                          ValueListenableBuilder<List<Store>>(
                            valueListenable: ValueNotifier(model.stores),
                            builder: (_, stores, __) => _buildDropdown(
                              context,
                              value: model.selectedStoreId.value,
                              items: stores
                                  .map((store) => store.id ?? '')
                                  .toList(),
                              displayItems: stores
                                  .map((store) => store.name ?? '')
                                  .toList(),
                              onChanged: (value) {
                                model.onStoreChanged(value);
                                model.getAllCustomers(storeId: value);
                              },
                              hintText: 'Filter by Store',
                            ),
                          ),
                          10.h.sbH,
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by name, email, or phone',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onChanged: (value) => model.getAllCustomers(
                              keyword: value,
                              storeId: model.selectedStoreId.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: ValueListenableBuilder<bool>(
                      valueListenable: model.isLoading,
                      builder: (_, isLoading, __) {
                        if (isLoading) {
                          return SliverToBoxAdapter(
                            child: Center(
                                child: SpinKitCircle(
                                    color: ColorValues.primaryColor,
                                    size: 50.w)),
                          );
                        }
                        if (model.allCustomers == null ||
                            model.allCustomers!.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                                child: AppText('No customers found',
                                    style: normalTextStyle)),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final customer = model.allCustomers![index];
                              return CustomerCard(
                                customer: customer,
                                onTap: () => navigationService.navigateToWidget(
                                  NewCustomers(customer: customer),
                                  transitionBuilder:
                                      (context, animation, _, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                              begin: Offset(1, 0),
                                              end: Offset.zero)
                                          .animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                                onDelete: () =>
                                    model.deleteCustomer(customer.id!),
                              );
                            },
                            childCount: model.allCustomers?.length ?? 0,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButton: model.stores.isEmpty
            ? null
            : FloatingActionButton(
                onPressed: () => navigationService.navigateToWidget(
                  NewCustomers(),
                  transitionBuilder: (context, animation, _, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
                              .animate(animation),
                      child: child,
                    );
                  },
                ),
                backgroundColor: ColorValues.primaryColor,
                child: Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    final display = displayItems ?? items;
    return Container(
      height: 55.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorValues.whiteColor,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: AppText(hintText,
              style: normalTextStyle12.copyWith(color: Color(0xFFD9D9D9))),
          value: items.contains(value) ? value : null,
          items: items
              .asMap()
              .entries
              .map((entry) => DropdownMenuItem(
                    value: entry.value,
                    child: AppText(
                        display[entry.key].toString().toCapitalized(),
                        style: normalTextStyle12),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
