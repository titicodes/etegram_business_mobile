//
//
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/app_widget/input_fields.dart';
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/strings.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';
// import 'package:etegram_business/locator.dart';
// import '../../../app_widget/app_text.dart';
// import '../../../app_widget/custom_listtile.dart';
// import '../../../constants/colors.dart';
// import '../../../service/local/user_service.dart';
// import '../vm/profle_vm.dart';
//
// class ProfileView extends StatelessWidget {
//   const ProfileView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final profileViewModel = locator<ProfileViewModel>();
//     final _firstNameController = TextEditingController(
//       text: locator<CustomerService>().customer?.firstName ?? '',
//     );
//
//     final _lastNameController = TextEditingController(
//       text: locator<CustomerService>().customer?.lastName ?? '',
//     );
//
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Profile",
//         onBackPressed: () => navigationService.goBack(),
//         showNotificationIcon: false,
//         showMenuIcon: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   SizedBox(
//                     width: 120,
//                     height: 120,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(100),
//                       child: SvgPicture.asset(SvgAssets.avatar),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: 35,
//                       height: 35,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100),
//                         color: ColorValues.greyColor,
//                       ),
//                       child: Icon(
//                         LineAwesomeIcons.camera_retro_solid,
//                         color: Colors.black,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               20.0.sbH,
//               // AppTextField(
//               //   hintText: StringValues.firstName,
//               //   initialValue: locator<CustomerService>().customer?.firstName,
//               // ),
//               AppTextField(
//                 hintText: StringValues.firstName,
//                 controller: _firstNameController,
//               ),
//               20.0.sbH,
//               AppTextField(
//                 hintText: StringValues.lastName,
//                 //initialValue: locator<CustomerService>().customer?.lastName,
//                 controller: _lastNameController,
//               ),
//               20.0.sbH,
//               AppTextField(
//                 hintText: StringValues.phoneNumber,
//                 prefix: Container(
//                   width: 150.sp,
//                   child: Row(
//                     children: [
//                       10.0.sbW,
//                       SvgPicture.asset(
//                         SvgAssets.flag,
//                         height: 16.sp,
//                         width: 16.sw,
//                       ),
//                       AppText('+234', style: normalTextStyle12),
//                     ],
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Phone number is required';
//                   }
//                   if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
//                     return 'Enter a valid 11-digit phone number starting with 0';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.number,
//               ),
//               20.0.sbH,
//               NxListTile(
//                 showBorder: false,
//                 trailing: Switch(
//                   value: profileViewModel.isPushNotificationSelected,
//                   onChanged: profileViewModel.togglePushedNotificationSwitch,
//                   activeColor: ColorValues.primaryColor,
//                 ),
//                 title: Text(
//                   StringValues.pushNotification,
//                   style: normalTextStyle,
//                 ),
//               ),
//               30.0.sbH,
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         width: MediaQuery.of(context).size.width,
//         height: 184,
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         color: Colors.white,
//         child: Column(
//           children: [
//             20.0.sbH,
//             AppButton(
//               text: StringValues.save,
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:etegram_business/locator.dart';
import '../../../app_widget/app_text.dart';
import '../../../app_widget/custom_listtile.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../service/local/user_service.dart';
import '../../../utils/snack_message.dart';
import '../vm/profle_vm.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = locator<ProfileViewModel>();
    final _firstNameController = TextEditingController(
      text: locator<CustomerService>().customer?.firstName ?? '',
    );
    final _lastNameController = TextEditingController(
      text: locator<CustomerService>().customer?.lastName ?? '',
    );

    return BaseView<ProfileViewModel>(
      onModelReady: (model) => model.init(),
      builder: (_, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: "Profile",
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: model.profileImageUrl,
                      builder: (context, imageUrl, _) => SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CircleAvatar(
                            backgroundColor: ColorValues.greyColor,
                            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? SvgPicture.asset(
                              SvgAssets.avatar,
                              height: 80,
                              width: 80,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => model.showImageSourceDialog(context),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ColorValues.primaryColor,
                          ),
                          child: const Icon(
                            LineAwesomeIcons.camera_retro_solid,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                20.0.sbH,
                AppText(
                  'Supported formats: JPEG, PNG, GIF, WebP, BMP (max 5MB)',
                  style: normalTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                ),
                20.0.sbH,
                AppTextField(
                  hintText: StringValues.firstName,
                  controller: _firstNameController,
                ),
                20.0.sbH,
                AppTextField(
                  hintText: StringValues.lastName,
                  controller: _lastNameController,
                ),
                20.0.sbH,
                AppTextField(
                  hintText: StringValues.phoneNumber,
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
                        AppText('+234', style: normalTextStyle12),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 11-digit phone number starting with 0';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                20.0.sbH,
                NxListTile(
                  showBorder: false,
                  trailing: Switch(
                    value: model.isPushNotificationSelected,
                    onChanged: model.togglePushNotification,
                    activeColor: ColorValues.primaryColor,
                  ),
                  title: Text(
                    StringValues.pushNotification,
                    style: normalTextStyle,
                  ),
                ),
                30.0.sbH,
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 184,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            children: [
              20.0.sbH,
              AppButton(
                text: StringValues.save,
                onTap: () {
                  // Implement save logic for profile updates
                  showCustomToast('Profile updated successfully!', success: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}