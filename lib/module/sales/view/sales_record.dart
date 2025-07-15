// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import '../../../app_widget/app_text.dart';
// import '../../../app_widget/custom_appbar.dart';
// import '../../../app_widget/custom_dropdown.dart';
// import '../../../constants/colors.dart';
// import '../../../constants/strings.dart';
// import '../../../constants/style.dart';
// import '../../../core/model/sales_records.dart';
// import '../vm/sales_record_vm.dart';
//
// class SalesRecordScreen extends StatelessWidget {
//   const SalesRecordScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<SalesRecordViewModel>(
//       onModelReady: (model) => model.init(),
//       builder: (_, model, child) => Scaffold(
//         backgroundColor: ColorValues.backgroundColor,
//         appBar: CustomAppBar(
//           title: StringValues.salesRecord,
//           onBackPressed: () => navigationService.goBack(),
//           showMenuIcon: false,
//           showNotificationIcon: false,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               AppText(
//                 StringValues.suppliers,
//                 style:
//                     headerTextStyle.copyWith(color: ColorValues.appTextColor),
//               ),
//               10.0.sbH,
//               ValueListenableBuilder<int>(
//                 valueListenable: model.totalSuppliers,
//                 builder: (context, count, _) => AppText(
//                     "Total Suppliers: $count",
//                     style: normalTextStyle12),
//               ),
//               10.0.sbH,
//               InkWell(
//                 onTap: () {},
//                 child: Container(
//                   height: 35,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: ColorValues.whiteColor,
//                   ),
//                   child: AppText(
//                     StringValues.tapToSeeSupplier,
//                     style: labelMedium,
//                   ),
//                 ),
//               ),
//               20.0.sbH,
//               CustomDropDown(
//                 width: double.infinity,
//                 hintText: "Time of Sales",
//                 hintStyle:
//                     normalTextStyle12.copyWith(color: ColorValues.appTextColor),
//                 items: model.timeOfSale,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                 prefix: Icon(Icons.calendar_today, color: Colors.grey),
//                 onChanged: model.onchangeSelectTimeOfSales,
//               ),
//               20.0.sbH,
//               CustomDropDown(
//                 width: double.infinity,
//                 hintText: "Select Payment Method",
//                 items: model.paymentMethod,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                 prefix: Icon(Icons.payment, color: Colors.grey),
//                 onChanged: model.onchangeSelectPaymentMethod,
//               ),
//               20.0.sbH,
//               CustomDropDown(
//                 width: double.infinity,
//                 hintText: "Customer",
//                 items: model.customer,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                 prefix: Icon(Icons.person, color: Colors.grey),
//                 onChanged: model.onchangeSelectedCustomer,
//               ),
//               20.0.sbH,
//               CustomDropDown(
//                 width: double.infinity,
//                 hintText: "Staff",
//                 items: model.staff,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                 prefix: Icon(Icons.person_outline, color: Colors.grey),
//                 onChanged: model.onchangeSelectStaff,
//               ),
//               20.0.sbH,
//               CustomDropDown(
//                 width: double.infinity,
//                 hintText: "Sort By",
//                 items: model.filterBySelection,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                 prefix: Icon(Icons.sort, color: Colors.grey),
//                 onChanged: model.onchangeSelectFilteredBy,
//               ),
//               20.0.sbH,
//               AppButton(
//                 text: StringValues.viewSalesRecord,
//                 onTap: () {
//                   navigationService.navigateTo('salesListRoute');
//                 },
//               ),
//               20.0.sbH,
//               ValueListenableBuilder<List<SalesRecord>>(
//                 valueListenable: model.salesHistory,
//                 builder: (context, records, _) {
//                   return records.isEmpty
//                       ? Center(
//                           child: AppText('No sales records found.',
//                               style: normalTextStyle))
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: records.length,
//                           itemBuilder: (context, index) {
//                             final record = records[index];
//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               child: ListTile(
//                                 title: AppText('Order #${record.id}',
//                                     style: normalTextStyle.copyWith(
//                                         fontWeight: FontWeight.bold)),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     AppText(
//                                         'Total: ₦${record.totalPriceWithTax.toStringAsFixed(2)}'),
//                                     AppText('Status: ${record.status}'),
//                                     AppText('Payment: ${record.paymentMethod}'),
//                                     AppText(
//                                         'Date: ${record.createdAt.toString().substring(0, 10)}'),
//                                     if (record.isCredit)
//                                       AppText(
//                                           'Customer: ${record.customerId ?? 'Unknown'}'),
//                                     if (record.supplierId != null)
//                                       AppText('Supplier: ${record.supplierId}'),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                 },
//               )
//             ],
//           ),
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

import '../../../routes/routes.dart';
import '../../../utils/string_extension.dart';

class SalesRecordScreen extends StatelessWidget {
  const SalesRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SalesRecordViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.salesRecord,
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
                      StringValues.suppliers,
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
                    AppButton(
                      text: StringValues.viewSalesRecord,
                      onTap: () {
                        navigationService.navigateTo(salesListRoute);
                      },
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
