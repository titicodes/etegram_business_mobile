import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/custom_dropdown.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';

class Expense extends StatelessWidget {
  const Expense({super.key});

  @override
  Widget build(BuildContext context) {
    var homeVm = locator<HomeViewModel>();
    return BaseView<ExpensesViewModel>(
      onModelReady: (model) {
        // Initialize the model if needed
        model.init();
      },
      builder: (_, model, child) => Scaffold(
        key: homeVm.scaffoldKey,
        drawer: NavDrawer(),
        backgroundColor: ColorValues.backgroundColor,
        body: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              title: "New Expenses",
              onBackPressed: () {
                navigationService.goBack();
              },
              showMenuIcon: true,
              onMenuPressed: () {
                homeVm.openDrawer();
              },
              showLogo: true,
              logoAsset: SvgAssets.appLogo,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: 16.0.padA,
                child: Form(
                  key: model.formKey, // Add the form key here
                  child: Column(
                    children: [
                      20.0.sbH,
                      CustomDropDown(
                        width: double.infinity,
                        hintText: "Select category...",
                        textStyle: normalTextStyle,
                        items: model.getCategoryListOptions(),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                        prefix: Icon(Icons.category, color: Colors.grey),
                        onChanged: (value) {
                          model.onChangedCategory(value);
                        },
                      ),
                      20.0.sbH,
                      CustomDropDown(
                        width: double.infinity,
                        hintText: "Select currency...",
                        hintStyle: normalTextStyle,
                        fillColor: ColorValues.appTextColor,
                        items: model.getCurrencyOption(),
                        textStyle: normalTextStyle,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                        prefix:
                            Icon(Icons.currency_exchange, color: Colors.grey),
                        onChanged: (value) {
                          model.onChangedCurrency(value);
                        },
                      ),
                      20.0.sbH,
                      CustomDropDown(
                        width: double.infinity,
                        hintText: "Select payment method...",
                        textStyle: normalTextStyle,
                        items: model.getPaymentOption(),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                        prefix: Icon(Icons.payment, color: Colors.grey),
                        onChanged: (value) {
                          model.onChangedPaymentMethod(value);
                        },
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Amount",
                        hintColor: ColorValues.appTextColor,
                        controller: model.amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // The controller already contains the value
                          // No need to set it explicitly
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      20.0.sbH,
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: ColorValues.whiteColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: TextField(
                          maxLines: 3,
                          controller: model.descriptionController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none,
                            hintStyle: normalTextStyle,
                            hintText: "Description...",
                          ),
                        ),
                      ),
                      20.0.sbH,
                      InkWell(
                        onTap: () => model.selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: ColorValues.whiteColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey),
                              SizedBox(width: 12),
                              Text(
                                model.selectedExpiryDate != null
                                    ? "${model.selectedExpiryDate!.day}/${model.selectedExpiryDate!.month}/${model.selectedExpiryDate!.year}"
                                    : "Select Date",
                                style: normalTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 112, // Reduced from 184 to avoid excessive bottom space
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: model.isFormValid,
            builder: (context, isValid, child) {
              return AppButton(
                text:
                    "Create Expense",
                onTap: isValid
                    ? () {
                        if (model.formKey.currentState!.validate()) {
                          model.createExpense();
                        }
                      }
                    : null,
                enabled: isValid,
              );
            },
          ),
        ),
      ),
    );
  }
}
