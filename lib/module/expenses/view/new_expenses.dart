import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_dropdown.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_widget/custom_sliver_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../vm/expenses_viewmodel.dart';


class NewExpenses extends StatelessWidget {
  const NewExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    var logic = locator<HomeViewModel>();
    final formKey = GlobalKey<FormState>(); // Add a form key

    return BaseView<ExpensesViewModel>(
      builder: (_, model, child) => Scaffold(
        key: logic.scaffoldKey,
        backgroundColor: ColorValues.backgroundColor,
        drawer: NavDrawer(),
        body: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              title: StringValues.newExpenses,
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
                child: Form(
                  key: formKey, // Wrap form elements with Form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.0.sbH,
                      StatefulBuilder(
                        builder: (context, setState) {
                          return CustomDropDown(
                            width: double.infinity,
                            hintText: "I am creating a...",
                            textStyle: normalTextStyle,
                            items: model.getCategoryListOptions(),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            prefix: Icon(Icons.category, color: Colors.grey),
                            onChanged: (value) {
                              model.onChangedCategory(value);
                            },
                          );
                        },
                      ),
                      20.0.sbH,
                      StatefulBuilder(
                        builder: (context, setState) {
                          return CustomDropDown(
                            width: double.infinity,
                            hintText: "I am creating a...",
                            textStyle: normalTextStyle,
                            items: model.getPaymentOption(),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            prefix: Icon(Icons.payment, color: Colors.grey),
                            onChanged: (value) {
                              model.onChangedPaymentMethod(value);
                            },
                          );
                        },
                      ),
                      20.0.sbH,
                      StatefulBuilder(
                        builder: (context, setState) {
                          return CustomDropDown(
                            width: double.infinity,
                            hintText: "I am creating a...",
                            hintStyle: normalTextStyle,
                            fillColor: ColorValues.appTextColor,
                            items: model.getCurrencyOption(),
                            textStyle: normalTextStyle,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            prefix: Icon(Icons.category, color: Colors.grey),
                            onChanged: (value) {
                              model.onChangedCurrency(value);
                            },
                          );
                        },
                      ),
                      20.0.sbH,
                      StatefulBuilder(
                        builder: (context, setState) {
                          return AppTextField(
                            hint: "Amount",
                            hintColor: ColorValues.appTextColor,
                            controller: model.amountController,
                            onChanged: (value) {
                              model.amountController.text = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Amount';
                              }
                              return null;
                            },
                          );
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
                              border: InputBorder.none,
                              hintStyle: normalTextStyle,
                              hintText: "Description...."),
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
          height: 184,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              20.0.sbH,
              ValueListenableBuilder<bool>(
                valueListenable: model.isFormValid,
                builder: (context, isValid, child) {
                  return AppButton(
                    text: StringValues.signUp,
                    onTap: isValid
                        ? () {
                      if(formKey.currentState!.validate()){
                        model.createExpense();
                      }
                    }
                        : null,
                    enabled: isValid,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}