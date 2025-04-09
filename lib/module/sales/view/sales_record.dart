import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/custom_dropdown.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../vm/sales_record_vm.dart';



class SalesRecord extends StatelessWidget {
  const SalesRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SalesRecordViewModel>(
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.salesRecord,
          onBackPressed: () {
            navigationService.goBack();
          },
          showMenuIcon: false,
          onMenuPressed: () {
            // Handle menu action
          },
          showNotificationIcon: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  StringValues.suppliers,
                  style:
                      headerTextStyle.copyWith(color: ColorValues.appTextColor),
                ),
                10.0.sbH,
                AppText("Total Suppliers: 0", style: normalTextStyle12),
                10.0.sbH,
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorValues.whiteColor),
                    child: AppText(
                      StringValues.tapToSeeSupplier,
                      style: labelMedium,
                    ),
                  ),
                ),
                20.0.sbH,
                CustomDropDown(
                  width: double.infinity,
                  hintText: "Time of Sales",
                  hintStyle: normalTextStyle12.copyWith(color: ColorValues.appTextColor),
                  items: model.timeOfSale,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  prefix: Icon(Icons.category,
                      color: Colors.grey), // Optional prefix icon
                  // borderDecoration: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   borderSide: BorderSide(color: ColorValues.greyColor, width: 1),
                  // ),
                  onChanged: (value) {
                    model.onchangeSelectTimeOfSales(value);
                  },
                ),
                20.0.sbH,
                CustomDropDown(
                  width: double.infinity,
                  hintText: "Select Payment Method",
                  items: model.paymentMethod,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  prefix: Icon(Icons.category,
                      color: Colors.grey), // Optional prefix icon
                  // borderDecoration: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   //borderSide: BorderSide(color: Colors.blue, width: 2),
                  // ),
                  onChanged: (value) {
                    model.onchangeSelectPaymentMethod(value);
                  },
                ),
                20.0.sbH,
                CustomDropDown(
                  width: double.infinity,
                  hintText: "Customer",
                  items: model.customer,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  prefix: Icon(Icons.category,
                      color: Colors.grey), // Optional prefix icon
                  onChanged: (value) {
                    model.onchangeSelectedCustomer(value);
                  },
                ),
                20.0.sbH,
                CustomDropDown(
                  width: double.infinity,
                  hintText: "Staff",
                  items: model.customer,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  prefix: Icon(Icons.category,
                      color: Colors.grey), // Optional prefix icon
                  // borderDecoration: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   borderSide: BorderSide(color: Colors.blue, width: 2),
                  // ),
                  onChanged: (value) {
                    model.onchangeSelectStaff(value);
                  },
                ),
                20.0.sbH,
                CustomDropDown(
                  width: double.infinity,
                  hintText: "Sort By",
                  items: model.filterBySelection,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  prefix: Icon(Icons.category,
                      color: Colors.grey), // Optional prefix icon
                  onChanged: (value) {
                    model.onchangeSelectFilteredBy(value);
                  },
                ),
                40.0.sbH,
                AppButton(
                  text: StringValues.viewSalesRecord,
                  onTap: (){

                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
