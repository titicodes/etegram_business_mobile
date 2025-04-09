import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
import 'package:etegram_business/module/sales/view/widgets/owed_widget.dart';
import 'package:etegram_business/module/sales/view/widgets/owing_widget.dart';
import 'package:etegram_business/module/sales/view/widgets/search_bar.dart';
import 'package:etegram_business/module/sales/vm/sales_record_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/custom_dropdown.dart';
import '../../../app_widget/custom_sliver_appbar.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/strings.dart';

class OwningRecords extends StatelessWidget {
  const OwningRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SalesRecordViewModel>(
      builder: (_, model, child) => Scaffold(
          drawer: const NavDrawer(),
          appBar: CustomAppBar(
            title: StringValues.newSupplier,
            onBackPressed: () {
              navigationService.goBack();
            },
            showMenuIcon: true,
            onMenuPressed: () {
              // Handle menu action
            },
            showNotificationIcon: false,
          ),
          body: CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                title: StringValues.newSupplier,
                onBackPressed: () {
                  navigationService.goBack();
                },
                showMenuIcon: false,
                onMenuPressed: () {},
                showNotificationIcon: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          StringValues.owningRecords,
                          style: headerTextStyle.copyWith(
                              color: ColorValues.appTextColor),
                        ),
                        10.0.sbH,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  StringValues.youAreOwing,
                                  style: normalTextStyle12,
                                ),
                                6.0.sbH,
                                AppText(
                                  "N  0.00",
                                  style: headerTextStyle,
                                ),
                                6.0.sbH,
                                RichText(
                                  text: TextSpan(
                                    text: StringValues.to,
                                    style: normalTextStyle12,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '0', style: normalTextStyle12),
                                      TextSpan(text: StringValues.people),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  StringValues.youAreOwed,
                                  style: normalTextStyle12,
                                ),
                                6.0.sbH,
                                AppText(
                                  "N  0.00",
                                  style: headerTextStyle,
                                ),
                                6.0.sbH,
                                RichText(
                                  text: TextSpan(
                                    text: StringValues.to,
                                    style: normalTextStyle12,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '0', style: normalTextStyle12),
                                      TextSpan(text: StringValues.people),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSearchBar(),
                            10.0.sbW,
                            CustomDropDown(
                              width: double.infinity,
                              hintText: "Filter by",
                              items: model.filterOwingRecode,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                              prefix: Icon(Icons.category,
                                  color: Colors.grey), // Optional prefix icon
                              onChanged: (value) {
                                model.onQueryChanged(value);
                              },
                            ),
                          ],
                        ),
                        20.0.sbH,
                        ValueListenableBuilder<int>(
                          valueListenable: model.tebIndex,
                          builder: (context, selectedIndex, child) {
                            return FlutterToggleTab(
                              width: 90,
                              borderRadius: 30,
                              height: 50,
                              selectedIndex: selectedIndex,
                              selectedBackgroundColors: const [
                                Colors.blue,
                                Colors.blueAccent,
                              ],
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              unSelectedTextStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              dataTabs: model.recordTaps,
                              selectedLabelIndex: (index) {
                                model.tebIndex.value =
                                    index; // Update the tab index
                              },
                              isScroll: false,
                            );
                          },
                        ),

                        20.0.sbH,

                        // Reactive Page Switching
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: model.tebIndex,
                            builder: (context, selectedIndex, child) {
                              return selectedIndex == 0
                                  ? OwingWidget()
                                  : OwedWidget();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
