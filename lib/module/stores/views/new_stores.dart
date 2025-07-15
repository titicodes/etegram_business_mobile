// Modified NewStores View
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../app_widget/app_button.dart';
// import '../../../app_widget/custom_appbar.dart';
// import '../../../app_widget/custom_dropdown.dart';
// import '../../../app_widget/input_fields.dart';
// import '../../../base/base_ui.dart';
// import '../../../constants/colors.dart';
// import '../../../constants/reuseable.dart';
// import '../../../constants/strings.dart';
// import '../../../constants/style.dart';
// import '../vm/stores_vm.dart';
//
// class NewStores extends StatelessWidget {
//   const NewStores({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<StoresViewModel>(
//       onModelReady: (model) => model.onInit(),
//       builder: (_, logic, child) => Scaffold(
//         backgroundColor: ColorValues.backgroundColor,
//         appBar: CustomAppBar(
//           title: logic.isEditing ? "Edit Store" : "Create Store",
//           onBackPressed: () => navigationService.goBack(),
//           showNotificationIcon: false,
//           showMenuIcon: false,
//         ),
//         body: logic.isLoading.value
//             ? const Center(child: SpinKitDoubleBounce(color: ColorValues.primaryColor, size: 50.0))
//             : SingleChildScrollView(
//           child: Padding(
//             padding: 16.0.padA,
//             child: Form(
//               key: logic.formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   20.0.sbH,
//                   Center(
//                     child: SvgPicture.asset(SvgAssets.appLogo),
//                   ),
//                   20.0.sbH,
//                   AnimatedBuilder(
//                     animation: logic,
//                     builder: (context, child) => RichText(
//                       text: TextSpan(
//                         text: StringValues.branchOf,
//                         style: normalTextStyle12,
//                         children: <TextSpan>[
//                           TextSpan(
//                             text: logic.businessName,
//                             style: normalTextStyle12.copyWith(color: ColorValues.primaryColor),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   20.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: "I am creating a...",
//                     items: logic.storesListOptions,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.category, color: Colors.grey),
//                     onChanged: logic.onStoreCategoryChanged,
//                   ),
//                   10.0.sbH,
//                   AppTextField(
//                     hint: StringValues.typStoreName,
//                     controller: logic.storeNameController,
//                     validator: (value) => value!.isEmpty ? 'Please enter your store name' : null,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: "Store type",
//                     items: logic.storeTypeOption,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.category, color: Colors.grey),
//                     onChanged: logic.onStoreTypeChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: "Store Classification",
//                     items: logic.classificationOptions,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.category, color: Colors.grey),
//                     onChanged: logic.onStoreClassificationChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: "Country",
//                     items: logic.countrySelectionOptions,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.category, color: Colors.grey),
//                     onChanged: logic.onCountryChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: logic.stateValue,
//                     items: logic.statesList,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.location_on, color: Colors.grey),
//                     onChanged: logic.onStateChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: logic.lgaValue,
//                     items: logic.lgaList,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.map, color: Colors.grey),
//                     onChanged: logic.onLGAChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: logic.wardValue,
//                     items: logic.wardList,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.my_location, color: Colors.grey),
//                     onChanged: logic.onWardChanged,
//                   ),
//                   10.0.sbH,
//                   CustomDropDown(
//                     width: double.infinity,
//                     hintText: "Currency",
//                     items: logic.currencyChoice,
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                     prefix: const Icon(Icons.category, color: Colors.grey),
//                     onChanged: logic.onCurrencyChanged,
//                   ),
//                   40.0.sbH,
//                   ValueListenableBuilder<bool>(
//                     valueListenable: logic.isFormValid,
//                     builder: (context, isValid, child) => AppButton(
//                       text: logic.isEditing ? StringValues.updateStore : StringValues.addStore,
//                       onTap: isValid ? () => logic.saveStore() : null,
//                     ),
//                   ),
//                   30.0.sbH,
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app_widget/app_button.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/custom_dropdown.dart';
import '../../../app_widget/input_fields.dart';
import '../../../app_widget/unfocus_widget.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';
import '../../../constants/style.dart';
import '../vm/stores_vm.dart';

class NewStores extends StatelessWidget {
  const NewStores({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<StoresViewModel>(
      onModelReady: (model) => model.onInit(),
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: logic.isEditing ? "Edit Store" : "Create Store",
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: false,
        ),
        body: logic.isLoading.value
            ? const Center(
            child: SpinKitDoubleBounce(
                color: ColorValues.primaryColor, size: 50.0))
            :
        // Wrap the entire content of the body with a GestureDetector
        UnFocusWidget(
          opaque: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: 16.0.padA,
              child: Form(
                key: logic.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.0.sbH,
                    Center(
                      child: SvgPicture.asset(SvgAssets.appLogo),
                    ),
                    20.0.sbH,
                    AnimatedBuilder(
                      animation: logic,
                      builder: (context, child) => RichText(
                        text: TextSpan(
                          text: StringValues.branchOf,
                          style: normalTextStyle12,
                          children: <TextSpan>[
                            TextSpan(
                              text: logic.businessName,
                              style: normalTextStyle12.copyWith(
                                  color: ColorValues.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    20.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "I am creating a...",
                      items: logic.storesListOptions,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix:
                      const Icon(Icons.category, color: Colors.grey),
                      onChanged: logic.onStoreCategoryChanged,
                    ),
                    10.0.sbH,
                    AppTextField(
                      hint: StringValues.typStoreName,
                      controller: logic.storeNameController,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your store name'
                          : null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        // This already dismisses the keyboard when "Done" is pressed
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Store type",
                      items: logic.storeTypeOption,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix:
                      const Icon(Icons.category, color: Colors.grey),
                      onChanged: logic.onStoreTypeChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Store Classification",
                      items: logic.classificationOptions,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix:
                      const Icon(Icons.category, color: Colors.grey),
                      onChanged: logic.onStoreClassificationChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Country",
                      items: logic.countrySelectionOptions,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix:
                      const Icon(Icons.category, color: Colors.grey),
                      onChanged: logic.onCountryChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: logic.stateValue,
                      items: logic.statesList,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix: const Icon(Icons.location_on,
                          color: Colors.grey),
                      onChanged: logic.onStateChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: logic.lgaValue,
                      items: logic.lgaList,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix: const Icon(Icons.map, color: Colors.grey),
                      onChanged: logic.onLGAChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: logic.wardValue,
                      items: logic.wardList,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix: const Icon(Icons.my_location,
                          color: Colors.grey),
                      onChanged: logic.onWardChanged,
                    ),
                    10.0.sbH,
                    CustomDropDown(
                      width: double.infinity,
                      hintText: "Currency",
                      items: logic.currencyChoice,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      prefix:
                      const Icon(Icons.category, color: Colors.grey),
                      onChanged: logic.onCurrencyChanged,
                    ),
                    40.0.sbH,
                    ValueListenableBuilder<bool>(
                      valueListenable: logic.isFormValid,
                      builder: (context, isValid, child) => AppButton(
                        text: logic.isEditing
                            ? StringValues.updateStore
                            : StringValues.addStore,
                        onTap: isValid
                            ? () {
                          logic.saveStore();
                          // Also unfocus the keyboard when the save button is tapped
                          FocusScope.of(context).unfocus();
                        }
                            : null,
                      ),
                    ),
                    30.0.sbH,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
