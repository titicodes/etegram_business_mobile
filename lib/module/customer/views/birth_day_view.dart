import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:intl/intl.dart';

import '../../../app_widget/app_button.dart';
import '../../../core/model/store_model.dart';
import '../../../routes/routes.dart';
import 'new_customer.dart';

class BirthdaysView extends StatelessWidget {
  const BirthdaysView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      onModelReady: (model) => model.getBirthdays(),
      builder: (_, model, __) => Scaffold(
        appBar: CustomAppBar(
          title: 'Birthdays',
          onBackPressed: navigationService.goBack,
          showMenuIcon: true,
          showNotificationIcon: false,
        ),
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
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: ValueListenableBuilder<List<Store>>(
                      valueListenable: ValueNotifier(model.stores),
                      builder: (_, stores, __) => _buildDropdown(
                        context,
                        value: model.selectedStoreId.value,
                        items: stores.map((store) => store.id ?? '').toList(),
                        displayItems:
                            stores.map((store) => store.name ?? '').toList(),
                        onChanged: (value) =>
                            model.getBirthdays(storeId: value),
                        hintText: 'Filter by Store',
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => model.getBirthdays(
                          storeId: model.selectedStoreId.value),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: model.isLoading,
                        builder: (_, isLoading, __) {
                          if (isLoading) {
                            return Center(
                                child: SpinKitCircle(
                                    color: ColorValues.primaryColor,
                                    size: 50.w));
                          }
                          if (model.allCustomers == null ||
                              model.allCustomers!.isEmpty) {
                            return Center(
                                child: AppText('No birthdays this month',
                                    style: normalTextStyle));
                          }
                          return ListView.builder(
                            itemCount: model.allCustomers!.length,
                            itemBuilder: (context, index) {
                              final customer = model.allCustomers![index];
                              final birthday = customer.birthday != null
                                  ? DateFormat('MMMM d').format(
                                      DateTime.parse(customer.birthday!))
                                  : 'Unknown';
                              return ListTile(
                                title: AppText(
                                  '${customer.firstName} ${customer.lastName}',
                                  style: normalTextStyle,
                                ),
                                subtitle: AppText(
                                  'Birthday: $birthday',
                                  style: normalTextStyle12,
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit,
                                      color: ColorValues.primaryColor),
                                  onPressed: () =>
                                      navigationService.navigateToWidget(
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
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
