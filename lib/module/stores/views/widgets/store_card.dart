import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/core/model/store_model.dart';
import 'package:etegram_business/module/stores/vm/stores_vm.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../../locator.dart';
import '../../../../routes/routes.dart';
import '../../../../service/local/user_service.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    var model = locator<StoresViewModel>();
    return GestureDetector(
      onTap: () {
        // Navigate to store details or set active store
        locator<CustomerService>().setActiveStore(store.id!);
        navigationService
            .navigateTo(dashboardRoute, arguments: {'storeId': store.id});
      },
      child: Container(
        height: height(context) * 0.2,
        width: width(context),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorValues.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  store.name ?? 'Unnamed Store',
                  style: titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorValues.primaryColor,
                  ),
                ),
                AppText(
                  store.classification ?? 'Main',
                  style: normalTextStyle.copyWith(
                    color: store.classification == 'Branch'
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ],
            ),
            8.0.sbH,
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: ColorValues.greyColor),
                4.0.sbW,
                Expanded(
                  child: AppText(
                    '${store.area ?? 'N/A'}, ${store.lga ?? 'N/A'}, ${store.state ?? 'N/A'}',
                    style: normalTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            8.0.sbH,
            Row(
              children: [
                const Icon(Icons.store, size: 16, color: ColorValues.greyColor),
                4.0.sbW,
                AppText(
                  'Type: ${store.type ?? 'N/A'}',
                  style: normalTextStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
            8.0.sbH,
            AppText(
              'Created by: ${store.owner}',
              style: normalTextStyle.copyWith(fontSize: 12, color: Colors.grey),
            ),
            8.0.sbH,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: ColorValues.primaryColor),
                  onPressed: () {
                    model.setEditing(store);
                    navigationService.navigateTo(createStoreRoute);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Store'),
                        content: Text(
                            'Are you sure you want to delete "${store.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await model.deleteStore(store.id!);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
