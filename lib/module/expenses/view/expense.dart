import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/custom_sliver_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/locator.dart';
import 'package:etegram_business/module/expenses/vm/expenses_viewmodel.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/home/vm/home_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_dropdown.dart';
import 'package:etegram_business/app_widget/input_fields.dart';

class Expense extends StatelessWidget {
  const Expense({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVm = locator<HomeViewModel>();
    return BaseView<ExpensesViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            key: homeVm.scaffoldKey,
            drawer: const NavDrawer(),
            backgroundColor: ColorValues.backgroundColor,
            body: CustomScrollView(
              slivers: [
                CustomSliverAppBar(
                  title: 'New Expense',
                  onBackPressed: () => navigationService.goBack(),
                  showMenuIcon: true,
                  onMenuPressed: () => homeVm.openDrawer(),
                  showLogo: true,
                  logoAsset: SvgAssets.appLogo,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: 16.0.padA,
                    child: Form(
                      key: model.formKey,
                      child: Column(
                        children: [
                          20.0.sbH,
                          CustomDropDown(
                            width: double.infinity,
                            hintText: 'Select category...',
                            textStyle: normalTextStyle,
                            items: model.getCategoryListOptions(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            prefix:
                                const Icon(Icons.category, color: Colors.grey),
                            onChanged: model.onChangedCategory,
                          ),
                          20.0.sbH,
                          CustomDropDown(
                            width: double.infinity,
                            hintText: 'Select currency...',
                            textStyle: normalTextStyle,
                            items: model.getCurrencyOption(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            prefix: const Icon(Icons.currency_exchange,
                                color: Colors.grey),
                            onChanged: model.onChangedCurrency,
                          ),
                          20.0.sbH,
                          CustomDropDown(
                            width: double.infinity,
                            hintText: 'Select payment method...',
                            textStyle: normalTextStyle,
                            items: model.getPaymentOption(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            prefix:
                                const Icon(Icons.payment, color: Colors.grey),
                            onChanged: model.onChangedPaymentMethod,
                          ),
                          20.0.sbH,
                          AppTextField(
                            hint: 'Amount',
                            hintColor: ColorValues.appTextColor,
                            controller: model.amountController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          20.0.sbH,
                          AppTextField(
                            hint: 'Description',
                            hintColor: ColorValues.appTextColor,
                            controller: model.descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                          ),
                          20.0.sbH,
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorValues.whiteColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextField(
                              maxLines: 3,
                              controller: model.notesController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintStyle: normalTextStyle,
                                hintText: 'Notes...',
                              ),
                            ),
                          ),
                          20.0.sbH,
                          InkWell(
                            onTap: () => model.selectDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: ColorValues.whiteColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Text(
                                    model.selectedDate != null
                                        ? '${model.selectedDate!.day}/${model.selectedDate!.month}/${model.selectedDate!.year}'
                                        : 'Select Date',
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
                ),
              ],
            ),
            bottomNavigationBar: Container(
              width: MediaQuery.of(context).size.width,
              height: 112,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: model.isFormValid,
                builder: (context, isValid, child) => AppButton(
                  text: 'Create Expense',
                  onTap: isValid ? () => model.createExpense(context) : null,
                  enabled: isValid,
                ),
              ),
            ),
          ),
          if (model.isLoading.value)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitFadingCircle(
                  color: ColorValues.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
