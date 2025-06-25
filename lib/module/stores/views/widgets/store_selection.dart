// Store Selection Screen
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../app_widget/app_button.dart';
import '../../../../app_widget/app_text.dart';
import '../../../../app_widget/custom_appbar.dart';
import '../../../../base/base_ui.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/reuseable.dart';
import '../../../../constants/style.dart';
import '../../../../routes/routes.dart';
import '../../vm/store_selection_vm.dart';

class StoreSelectionView extends StatelessWidget {
  const StoreSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<StoreSelectionViewModel>(
      onModelReady: (model) => model.fetchStores(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar(
          title: "Select Active Store",
          onBackPressed: () {},
        ),
        backgroundColor: ColorValues.backgroundColor,
        body: model.isLoading.value
            ? const Center(
                child: SpinKitDoubleBounce(
                    color: ColorValues.primaryColor, size: 50.0))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                        "Choose your active store for managing products and sales.",
                        style: normalTextStyle),
                    20.0.sbH,
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.stores.length,
                        itemBuilder: (context, index) {
                          final store = model.stores[index];
                          return ListTile(
                            title: AppText(store.name ?? "Unnamed Store"),
                            subtitle: AppText(
                                "${store.classification} - ${store.lga}, ${store.state}"),
                            trailing: model.activeStoreId == store.id
                                ? const Icon(Icons.check_circle,
                                    color: ColorValues.primaryColor)
                                : null,
                            onTap: () =>
                                model.setActiveStore(store.id!, context),
                          );
                        },
                      ),
                    ),
                    20.0.sbH,
                    AppButton(
                      text: "Create New Store",
                      onTap: () => navigationService.navigateTo(createStoreRoute),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
