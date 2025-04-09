import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/module/customer/vm/customer_vm.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';

class NewCustomers extends StatelessWidget {
  const NewCustomers({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CustomerViewModel>(
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(title: "", onBackPressed: (){
          navigationService.goBack();
        }),
        backgroundColor: ColorValues.backgroundColor,
        body: Form(
          key: model.formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.0.sbH,
                    Center(
                      child: SvgPicture.asset(SvgAssets.appLogo),
                    ),
                    12.0.sbH,
                    AppText(
                      StringValues.newCustomers,
                      style: titleLarge,
                    ),
                    12.0.sbH,
                    AppTextField(
                      hint: StringValues.firstName,
                      controller: model.firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    12.0.sbH,
                    AppTextField(
                      hint: StringValues.lastName,
                      controller: model.lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    12.0.sbH,
                    AppTextField(
                      hint: StringValues.enterEmail,
                      controller: model.emailNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    12.0.sbH,
                    AppTextField(
                      hint: StringValues.phoneNumber,
                      prefix: Container(
                        width: 150.sp,
                        child: Row(
                          children: [
                            10.0.sbW,
                            SvgPicture.asset(
                              SvgAssets.flag,
                              height: 16.sp,
                              width: 16.sw,
                            ),
                            AppText('  +234',
                                style:
                                    normalTextStyle12), // +234 is only for display
                          ],
                        ),
                      ),
                      controller: model.phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                          return 'Enter a valid 11-digit phone number starting with 0';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        model.phoneNumber = value;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    12.0.sbH,
                    GestureDetector(
                      onTap: () => model.selectDate(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText("Birthday",),
                          Text(
                            model.selectedExpiryDate != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(model.selectedExpiryDate!)
                                : "Pick Date",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: ColorValues.appTextColor),
                          ),
                        ],
                      ),
                    ),
                    12.0.sbH,
                    AppTextField(
                      hintColor: ColorValues.appTextColor,
                      prefix: Icon(Icons.location_on_sharp),
                      isPassword: false,
                      hint: "Address",
                      controller: model.passwordNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      onChanged: model.onChange,
                    ),
                    16.0.sbH,
                    _buildDropdown(context,
                        value: model.country,
                        items: model.countryList, onChanged: (value) {
                      model.onCountryChanged(value ?? "");
                    }, hintText: 'Country'),
                    12.0.sbH,
                    _buildDropdown(context,
                        value: model.stateValue,
                        items: model.statesList, onChanged: (value) {
                      model.onStateChanged(value ?? "");
                    }, hintText: 'State'),
                    16.0.sbH,
                    _buildDropdown(context,
                        value: model.lgaValue,
                        items: model.lgaList, onChanged: (value) {
                      model.onLGAChanged(value ?? "");
                    }, hintText: 'City'),
                    12.0.sbH,
                    Container(
                      decoration: BoxDecoration(
                        color: ColorValues.whiteColor
                      ),
                      child: TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Extra Details",
                          border: InputBorder.none,
                          hintStyle: normalTextStyle,
                          prefix: Icon(Icons.note_add),
                        ),
                      ),
                    ),
                    12.0.sbH,
                    ValueListenableBuilder<bool>(
                      valueListenable: model.isFormValid,
                      builder: (context, isValid, child) {
                        return AppButton(
                          text: StringValues.signUp,
                          onTap: isValid
                              ? () {
                                  model.submit();
                                }
                              : null,
                          enabled: isValid,
                        );
                      },
                    ),
                    40.0.sbH,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    String? selectedValue = items.contains(value) ? value : null;

    return Padding(
      padding: EdgeInsets.all(0.sp),
      child: Container(
        height: 55.sp,
        width: width(context),
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.sp),
        decoration: BoxDecoration(
          color: ColorValues.whiteColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: AppText(
                hintText,
                style: TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontFamily: "Poppins",
                    fontSize: 12),
              ),
            ),
            value: selectedValue,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: AppText(item.toCapitalized()),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              onChanged(newValue);
            },
            icon: Icon(Icons.arrow_drop_down),
            elevation: 0,
            selectedItemBuilder: (BuildContext context) {
              return items.map((String value) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.sp),
                  child: AppText(
                    value.toCapitalized(),
                    style: normalTextStyle12,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
