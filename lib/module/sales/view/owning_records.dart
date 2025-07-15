// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
// import 'package:etegram_business/module/sales/view/widgets/owed_widget.dart';
// import 'package:etegram_business/module/sales/view/widgets/owing_widget.dart';
//
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import '../../../app_widget/custom_appbar.dart';
// import '../../../app_widget/custom_dropdown.dart';
// import '../../../app_widget/custom_sliver_appbar.dart';
// import '../../../constants/reuseable.dart';
// import '../../../constants/strings.dart';
// import '../vm/sales_record_vm.dart';
//
// class OwningRecords extends StatelessWidget {
//   const OwningRecords({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<SalesRecordViewModel>(
//       onModelReady: (model) => model.init(),
//       builder: (_, model, child) => Scaffold(
//         drawer: const NavDrawer(),
//         appBar: CustomAppBar(
//           title: StringValues.owningRecords,
//           onBackPressed: () => navigationService.goBack(),
//           showMenuIcon: true,
//           showNotificationIcon: false,
//         ),
//         body: CustomScrollView(
//           slivers: [
//             CustomSliverAppBar(
//               title: StringValues.owningRecords,
//               onBackPressed: () => navigationService.goBack(),
//               showMenuIcon: false,
//               showNotificationIcon: false,
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       StringValues.owningRecords,
//                       style: headerTextStyle.copyWith(
//                           color: ColorValues.appTextColor),
//                     ),
//                     10.0.sbH,
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(StringValues.youAreOwing,
//                                 style: normalTextStyle12),
//                             6.0.sbH,
//                             ValueListenableBuilder<double>(
//                               valueListenable: model.totalOwing,
//                               builder: (context, total, _) => AppText(
//                                 "₦${total.toStringAsFixed(2)}",
//                                 style: headerTextStyle,
//                               ),
//                             ),
//                             6.0.sbH,
//                             ValueListenableBuilder<int>(
//                               valueListenable: model.totalSuppliers,
//                               builder: (context, count, _) => RichText(
//                                 text: TextSpan(
//                                   text: StringValues.to,
//                                   style: normalTextStyle12,
//                                   children: [
//                                     TextSpan(
//                                         text: ' $count ',
//                                         style: normalTextStyle12),
//                                     TextSpan(text: StringValues.suppliers),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(StringValues.youAreOwed,
//                                 style: normalTextStyle12),
//                             6.0.sbH,
//                             ValueListenableBuilder<double>(
//                               valueListenable: model.totalOwed,
//                               builder: (context, total, _) => AppText(
//                                 "₦${total.toStringAsFixed(2)}",
//                                 style: headerTextStyle,
//                               ),
//                             ),
//                             6.0.sbH,
//                             ValueListenableBuilder<int>(
//                               valueListenable: model.totalCustomers,
//                               builder: (context, count, _) => RichText(
//                                 text: TextSpan(
//                                   text: StringValues.to,
//                                   style: normalTextStyle12,
//                                   children: [
//                                     TextSpan(
//                                         text: ' $count ',
//                                         style: normalTextStyle12),
//                                     TextSpan(text: StringValues.customer),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     20.0.sbH,
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: CustomDropDown(
//                             hintText: "Filter by",
//                             items: model.filterOwingRecord,
//                             icon:
//                                 Icon(Icons.arrow_drop_down, color: Colors.grey),
//                             prefix: Icon(Icons.filter_list, color: Colors.grey),
//                             onChanged: model.onQueryChanged,
//                           ),
//                         ),
//                       ],
//                     ),
//                     20.0.sbH,
//                     ValueListenableBuilder<int>(
//                       valueListenable: model.tabIndex,
//                       builder: (context, selectedIndex, child) =>
//                           FlutterToggleTab(
//                         width: 90,
//                         borderRadius: 30,
//                         height: 50,
//                         selectedIndex: selectedIndex,
//                         selectedBackgroundColors: const [
//                           Colors.blue,
//                           Colors.blueAccent
//                         ],
//                         selectedTextStyle: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         unSelectedTextStyle: const TextStyle(
//                           color: Colors.black87,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         dataTabs: model.recordTabs,
//                         selectedLabelIndex: (index) {
//                           model.tabIndex.value = index;
//                         },
//                         isScroll: false,
//                       ),
//                     ),
//                     20.0.sbH,
//                     ValueListenableBuilder<int>(
//                       valueListenable: model.tabIndex,
//                       builder: (context, selectedIndex, child) =>
//                           selectedIndex == 0
//                               ? OwingWidget(records: model.owingRecords)
//                               : OwedWidget(records: model.owedRecords),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_dropdown.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/sales_records.dart';
import 'package:etegram_business/module/sales/vm/sales_record_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:etegram_business/utils/snack_message.dart';

import '../../../utils/string_extension.dart';

class OwningRecords extends StatelessWidget {
  const OwningRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SalesRecordViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: 'Owing Records',
          onBackPressed: () => navigationService.goBack(),
          showMenuIcon: false,
          showNotificationIcon: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FlutterToggleTab(
                dataTabs: model.recordTabs,
                selectedIndex: model.selectedIndex,
                selectedTextStyle:
                    normalTextStyle.copyWith(color: ColorValues.whiteColor),
                unSelectedTextStyle:
                    normalTextStyle.copyWith(color: ColorValues.appTextColor),
                selectedBackgroundColors: const [ColorValues.primaryColor],
                unSelectedBackgroundColors: const [ColorValues.backgroundColor],
                width: 90,
                height: 40,
                selectedLabelIndex: (index) => model.onTabChanged(index),
                isScroll: false,
                borderRadius: 20,
                isShadowEnable: true,
                isInnerShadowEnable: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                      'Owing Summary',
                      style: headerTextStyle.copyWith(
                          color: ColorValues.appTextColor),
                    ),
                    10.0.sbH,
                    ValueListenableBuilder<int>(
                      valueListenable: model.totalSuppliers,
                      builder: (context, count, _) => AppText(
                        "Total Suppliers: $count",
                        style: normalTextStyle12,
                      ),
                    ),
                    10.0.sbH,
                    ValueListenableBuilder<double>(
                      valueListenable: model.totalOwing,
                      builder: (context, total, _) => AppText(
                        "Total Owing: ${formatPrice(total.toStringAsFixed(2))}",
                        style: normalTextStyle12,
                      ),
                    ),
                    10.0.sbH,
                    ValueListenableBuilder<int>(
                      valueListenable: model.totalCustomers,
                      builder: (context, count, _) => AppText(
                        "Total Customers: $count",
                        style: normalTextStyle12,
                      ),
                    ),
                    10.0.sbH,
                    ValueListenableBuilder<double>(
                      valueListenable: model.totalOwed,
                      builder: (context, total, _) => AppText(
                        "Total Owed: ${formatPrice(total.toStringAsFixed(2))}",
                        style: normalTextStyle12,
                      ),
                    ),
                    10.0.sbH,
                    InkWell(
                      onTap: () {
                        showCustomToast(
                            'Supplier details not implemented yet.');
                      },
                      child: Container(
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorValues.whiteColor,
                        ),
                        child: AppText(
                          StringValues.tapToSeeSupplier,
                          style: labelMedium,
                        ),
                      ),
                    ),
                    20.0.sbH,
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by order ID, customer, or supplier',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: model.onQueryChanged,
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Time of Sales",
                      hintStyle: normalTextStyle12.copyWith(
                          color: ColorValues.appTextColor),
                      items: model.timeOfSale,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      prefix:
                          const Icon(Icons.calendar_today, color: Colors.grey),
                      onChanged: model.onchangeSelectTimeOfSales,
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Select Payment Method",
                      items: model.paymentMethod,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      prefix: const Icon(Icons.payment, color: Colors.grey),
                      onChanged: model.onchangeSelectPaymentMethod,
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Customer",
                      items: model.customer,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      prefix: const Icon(Icons.person, color: Colors.grey),
                      onChanged: model.onchangeSelectedCustomer,
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "User",
                      items: model.userSelection,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      prefix:
                          const Icon(Icons.person_outline, color: Colors.grey),
                      onChanged: model.onchangeSelectUser,
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Sort By",
                      items: model.filterBySelection,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      prefix: const Icon(Icons.sort, color: Colors.grey),
                      onChanged: model.onchangeSelectFilteredBy,
                    ),
                    20.0.sbH,
                    ValueListenableBuilder<bool>(
                      valueListenable: model.isLoading,
                      builder: (context, isLoading, _) {
                        if (isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return ValueListenableBuilder<int>(
                          valueListenable: model.tabIndex,
                          builder: (context, tabIndex, _) {
                            final records = tabIndex == 0
                                ? model.salesHistory
                                : tabIndex == 1
                                    ? model.owingRecords
                                    : model.owedRecords;
                            return ValueListenableBuilder<List<SalesRecord>>(
                              valueListenable: records,
                              builder: (context, recordList, _) {
                                if (recordList.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AppText(
                                          'No ${model.recordTabs[tabIndex].title?.toLowerCase()} records found.',
                                          style: normalTextStyle,
                                        ),
                                        AppButton(
                                          text: 'Retry',
                                          onTap: () => model.init(),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recordList.length,
                                  itemBuilder: (context, index) {
                                    final record = recordList[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ListTile(
                                        title: AppText(
                                          'Order #${record.id}',
                                          style: normalTextStyle.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppText(
                                                'Total: ${formatPrice(record.totalPriceWithTax.toStringAsFixed(2))}'),
                                            AppText('Status: ${record.status}'),
                                            AppText(
                                                'Payment: ${record.paymentMethod}'),
                                            AppText(
                                                'Date: ${record.createdAt.toString().substring(0, 10)}'),
                                            if (record.isCredit)
                                              AppText(
                                                  'Customer: ${record.customerId ?? 'Unknown'}'),
                                            if (record.supplierId != null)
                                              AppText(
                                                  'Supplier: ${record.supplierId}'),
                                            AppText('User: ${record.userId}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
