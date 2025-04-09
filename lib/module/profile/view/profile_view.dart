import 'dart:io';

import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/module/profile/vm/profle_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_widget/custom_appbar.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileViewModel>(
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.newSupplier,
          onBackPressed: () {},
          showMenuIcon: true,
          onMenuPressed: () {
            // Handle menu action
          },
          showNotificationIcon: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: model.isEdit
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                AnimatedContainer(
                  height: model.isEdit ? 105 : 45,
                  width: model.isEdit ? 105 : 45,
                  duration: const Duration(milliseconds: 300),
                  child: model.isEdit
                      ? Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 105,
                              width: 105,
                              decoration: ShapeDecoration(
                                  // image: DecorationImage(
                                  //   image: CachedNetworkImageProvider(
                                  //       model.user.profileImage ?? ""),
                                  //   fit: BoxFit.cover,
                                  // ),
                                  shape: const OvalBorder(),
                                  color: ColorValues.greyColor),
                              child: model.selectedImageFile == null
                                  ? null
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(52.5),
                                      child: Image.file(
                                        File(model.selectedImageFile?.path ??
                                            ""),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            !model.showEdit
                                ? InkWell(
                                    onTap: model.pickImage,
                                    borderRadius: BorderRadius.circular(17.5),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const ShapeDecoration(
                                        color: Color(0xFFE8F9F1),
                                        shape: OvalBorder(),
                                      ),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        SvgAssets.avatar,
                                        height: 16,
                                        width: 16,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: model.selectImage,
                                        child: Container(
                                          height: 36,
                                          width: 36,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFE8F9F1),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Icon(
                                            Icons.camera,
                                            color: ColorValues.primaryColor,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => model.selectImage(
                                            source: ImageSource.gallery),
                                        child: Container(
                                          height: 36,
                                          width: 36,
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFE8F9F1),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Icon(
                                            Icons.image,
                                            color: ColorValues.primaryColor,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                          ],
                        )
                      : Container(
                          height: 45,
                          width: 45,
                          decoration: ShapeDecoration(
                              // image: DecorationImage(
                              //   image: CachedNetworkImageProvider(
                              //       model.user.profileImage ?? ""),
                              //   fit: BoxFit.cover,
                              // ),
                              shape: const OvalBorder(),
                              color: ColorValues.greyColor)),
                ),
                model.isEdit ? 0.0.sbW : 6.0.sbW,
                model.isEdit
                    ? 0.0.sbW
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AppText(
                          //   "${model.user.firstName ?? ""} ${model.user.lastName}",
                          //   weight: FontWeight.w600,
                          //   size: 13,
                          // ),
                          // AppText(
                          //   model.user.email ?? "",
                          //   size: 11,
                          //   color: hintTextColor,
                          // ),
                        ],
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
