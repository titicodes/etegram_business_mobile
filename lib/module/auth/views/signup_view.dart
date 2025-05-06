import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/utils/string_extension.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/assets.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../viewmodel/signup_vm.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SignUpViewModel>(
      notDefaultLoading: true,
      onModelReady: (model) {
        model.loadStatesAndLGAs();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        body: Form(
          key: model.formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  60.0.sbH,
                  Center(
                    child: SvgPicture.asset(SvgAssets.appLogo),
                  ),
                  12.0.sbH,
                  AppText(
                    StringValues.createAccount,
                    style: titleLarge,
                  ),
                  6.0.sbH,
                  AppText(
                    StringValues.onlyTakesMinute,
                    style: normalTextStyle12,
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
                          AppText('  +234', style: normalTextStyle12), // +234 is only for display
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
                  AppTextField(
                    hintColor: ColorValues.appTextColor,
                    isPassword: true,
                    hint: "Create password",
                    controller: model.passwordNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onChanged: model.onChange,
                  ),
                  12.0.sbH,
                  AppTextField(
                    hint: "Business Name",
                    controller: model.userNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  12.0.sbH,
                  _buildDropdown(context,
                      value: model.businessType,
                      items: model.businessTypeSelections, onChanged: (value) {
                    model.onChangedBusiness(value ?? "");
                  }, hintText: 'Business Type'),
                  if (model.businessType == 'Other')
                    Column(
                      children: [
                        10.0.sbH,
                        AppTextField(
                          hintText: 'If others please specify ',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify the business type';
                            }
                            return null;
                          },
                        ),
                      ],
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
                  _buildDropdown(context,
                      value: model.wardValue,
                      items: model.wardList, onChanged: (value) {
                    model.onWardChanged(value ?? "");
                  }, hintText: 'Area'),
                  16.0.sbH,
                  _buildDropdown(context,
                      value: model.selectedCurrency,
                      items: model.currency, onChanged: (value) {
                    model.onChangedCurrency(value ?? "");
                  }, hintText: 'Currency'),
                  if (model.selectedCurrency == 'Other')
                    Column(
                      children: [
                        10.0.sbH,
                        AppTextField(
                          hintText: 'If others please specify ',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify the currency';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  12.0.sbH,
                  Row(
                    children: [
                      Checkbox(
                        value: model.isChecked,
                        onChanged: (bool? value) {
                          model.isChecked = value ?? false;
                          model.validateForm();
                        },
                      ),
                      Expanded(
                        child: Text('I agree to the Terms and Privacy Policy'),
                      ),
                      40.0.sbH,
                    ],
                  ),
                  // ValueListenableBuilder<bool>(
                  //   valueListenable: model.isFormValid,
                  //   builder: (context, isValid, child) {
                  //     return AppButton(
                  //       text: StringValues.signUp,
                  //       onTap: isValid
                  //           ? () {
                  //               model.submit();
                  //             }
                  //           : null,
                  //       enabled: isValid,
                  //     );
                  //   },
                  // ),
                  ValueListenableBuilder<bool>(
                    valueListenable: model.isFormValid,
                    builder: (context, isValid, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: model.isLoading,
                        builder: (context, isLoading, _) {
                          return AppButton(
                            enabled: isValid && !isLoading,
                            onTap: (isValid && !isLoading)
                                ? () {
                              model.submit();
                            }
                                : null,
                            child: isLoading
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Signing up, please wait...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )
                                : Text(
                              StringValues.signUp,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  16.0.sbH,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: StringValues.dontHaveAccount,
                              style: subStyle.copyWith(fontSize: 15.sp),
                            ),
                            TextSpan(
                              text: StringValues.signIn,
                              style: subUnderlineGreenStyle.copyWith(
                                  fontSize: 15.sp,
                                  color: ColorValues.primaryColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Future.delayed(Duration.zero, () {
                                    model.goToSignInView();
                                  });
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  40.0.sbH,
                ],
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
