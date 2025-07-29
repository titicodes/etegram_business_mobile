import 'package:etegram_business/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/customer_response.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';

import '../../../core/model/store_model.dart'; // Ensure Store is imported for the dropdown
import '../../../routes/routes.dart'; // Ensure routes are correctly imported

class NewCustomers extends StatelessWidget {
  final CustomerData? customer;

  const NewCustomers({super.key, this.customer});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      onModelReady: (model) {
        // Log to see when model is ready and what the store status is
        print('NewCustomers: onModelReady called.');
        print(
            'NewCustomers: Initial customer data: ${customer != null ? 'present' : 'null'}');
        if (customer != null) {
          model.populateForm(customer!);
        }
        model.initState(); // Call ViewModel's initState
      },
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: customer != null ? 'Edit Customer' : 'New Customer',
          onBackPressed: navigationService.goBack,
          showMenuIcon: false,
        ),
        backgroundColor: ColorValues.backgroundColor,
        // MODIFIED: Listen to model.storesNotifier directly (if added in ViewModel)
        // If storesNotifier is NOT in ViewModel, this will default to using model.stores getter.
        // It's important that model.stores correctly reflects the state from customerService.stores.
        body: ValueListenableBuilder<List<Store>>(
          // If customer_vm has storesNotifier, use `model.storesNotifier` here.
          // Otherwise, if `stores` getter is directly returning customerService.stores,
          // and customerService updates its internal stores list, you might need to
          // wrap `model.stores` in its own ValueNotifier for UI reactivity, or
          // ensure customerService has a mechanism to notify its listeners.
          // For now, assuming model.stores is sufficiently reactive due to `notifyListeners()` in ViewModel
          // and the underlying customerService.stores being updated.
          valueListenable: ValueNotifier(model.stores), // Revert to this for now, if storesNotifier is not added
          builder: (context, stores, _) {
            // Log store status for debugging
            print('NewCustomers UI: Stores list is empty? ${stores.isEmpty}');
            print('NewCustomers UI: Number of stores: ${stores.length}');
            if (stores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText('No stores available. Please create a store.',
                        style: normalTextStyle),
                    20.h.sbH,
                    AppButton(
                      text: 'Create Store',
                      onTap: () {
                        // Navigate to create store. No forced login here.
                        navigationService.navigateTo(createStoreRoute);
                      },
                    ),
                    // Optionally, if you still face login issues, add a debug button for login status
                    // 20.h.sbH,
                    // AppButton(
                    //   text: 'Check Login Status (Debug)',
                    //   onTap: () {
                    //     showCustomToast('Logged In: ${model.customerService.isUserLoggedIn}', success: model.customerService.isUserLoggedIn);
                    //   },
                    // ),
                  ],
                ),
              );
            } else {
              return Form(
                key: model.formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: SvgPicture.asset(SvgAssets.appLogo,
                              height: 60.h)),
                      20.h.sbH,
                      AppText(
                        customer != null
                            ? 'Edit Customer Details'
                            : StringValues.newCustomers,
                        style: titleLarge,
                      ),
                      16.h.sbH,
                      AppTextField(
                        hint: StringValues.firstName,
                        controller: model.firstNameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter first name'
                            : null,
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: StringValues.lastName,
                        controller: model.lastNameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter last name'
                            : null,
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: StringValues.enterEmail,
                        controller: model.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: StringValues.phoneNumber,
                        prefix: Container(
                          width: 100.w,
                          child: Row(
                            children: [
                              10.w.sbW,
                              SvgPicture.asset(SvgAssets.flag,
                                  height: 16.h, width: 16.w),
                              AppText(' +234', style: normalTextStyle12),
                            ],
                          ),
                        ),
                        controller: model.phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter phone number';
                          if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 11-digit phone number starting with 0';
                          }
                          return null;
                        },
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: 'Extra Phone (Optional)',
                        controller: model.extraPhoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !RegExp(r'^0\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 11-digit phone number or leave empty';
                          }
                          return null;
                        },
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: 'Address',
                        controller: model.addressController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter address'
                            : null,
                        onChanged: (_) => model.validateForm(),
                      ),
                      12.h.sbH,
                      GestureDetector(
                        onTap: () => model.selectBirthday(context),
                        child: Container(
                          height: 55.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ColorValues.whiteColor,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          padding: EdgeInsets.all(8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText('Birthday', style: normalTextStyle12),
                              ValueListenableBuilder<DateTime?>(
                                valueListenable:
                                ValueNotifier(model.selectedBirthday),
                                builder: (_, date, __) => AppText(
                                  date != null
                                      ? DateFormat('yyyy-MM-dd').format(date)
                                      : 'Pick Birthday',
                                  style: normalTextStyle12.copyWith(
                                      color: ColorValues.appTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      12.h.sbH,
                      // The Dropdown now correctly uses the 'stores' list from the ViewModel (which uses CustomerService.stores)
                      ValueListenableBuilder<String?>(
                        valueListenable: model
                            .selectedStoreId, // Listen directly to selectedStoreId's changes
                        builder: (_, selectedId, __) => _buildDropdown(
                          context,
                          value: selectedId,
                          items: stores
                              .map((store) => store.id ?? '')
                              .toList(), // Use the 'stores' from ValueListenableBuilder
                          displayItems: stores
                              .map((store) => store.name ?? '')
                              .toList(), // Use the 'stores' from ValueListenableBuilder
                          onChanged: model.onStoreChanged,
                          hintText: 'Select Store',
                        ),
                      ),
                      12.h.sbH,
                      _buildDropdown(
                        context,
                        value: model.country,
                        items: model.countryList,
                        onChanged: model.onCountryChanged,
                        hintText: 'Select Country',
                      ),
                      12.h.sbH,
                      ValueListenableBuilder<List<String>>(
                        valueListenable: ValueNotifier(model.statesList),
                        builder: (_, states, __) => _buildDropdown(
                          context,
                          value: model.state,
                          items: states,
                          onChanged: model.onStateChanged,
                          hintText: 'Select State',
                        ),
                      ),
                      12.h.sbH,
                      ValueListenableBuilder<List<String>>(
                        valueListenable: ValueNotifier(model.lgaList),
                        builder: (_, lgas, __) => _buildDropdown(
                          context,
                          value: model.lga,
                          items: lgas,
                          onChanged: model.onLGAChanged,
                          hintText: 'Select LGA',
                        ),
                      ),
                      12.h.sbH,
                      ValueListenableBuilder<List<String>>(
                        valueListenable: ValueNotifier(model.wardList),
                        builder: (_, wards, __) => _buildDropdown(
                          context,
                          value: model.area,
                          items: wards,
                          onChanged: model.onAreaChanged,
                          hintText: 'Select Area',
                        ),
                      ),
                      12.h.sbH,
                      AppTextField(
                        hint: 'Extra Details (Optional)',
                        controller: model.extraDetailsController,
                        maxLines: 3,
                        prefix: Icon(Icons.note_add),
                        onChanged: (_) => model.validateForm(),
                      ),
                      20.h.sbH,
                      ValueListenableBuilder<bool>(
                        valueListenable: model.isFormValid,
                        builder: (_, isValid, __) => AppButton(
                          text: customer != null
                              ? 'Update Customer'
                              : 'Create Customer',
                          isLoading: model.isLoading.value, // This is correctly hooked up
                          enabled: isValid,
                          onTap: isValid
                              ? () => customer != null
                              ? model.updateCustomer(customer!.id!)
                              : model.submit()
                              : null,
                        ),
                      ),
                      40.h.sbH,
                    ],
                  ),
                ),
              );
            }
          },
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
    // Ensure selectedValue is one of the valid items, otherwise set to null to show hintText
    final selectedValue = items.contains(value) ? value : null;
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
          value: selectedValue,
          items: items
              .asMap()
              .entries
              .map((entry) => DropdownMenuItem(
            value: entry.value,
            child: AppText(
              display[entry.key].toString().toCapitalized(),
              style: normalTextStyle12,
            ),
          ))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
