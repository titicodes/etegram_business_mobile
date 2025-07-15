import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants/assets.dart';

class HowItWorksView extends StatelessWidget {
  const HowItWorksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.backgroundColor,
      appBar: CustomAppBar(
        title: "How It Works",
        onBackPressed: () => navigationService.goBack(),
        backgroundColor: ColorValues.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Learn How to Use the App',
              style: subHeaderTextStyle,
            ),
            16.0.sbH,
            AppText(
              'Our app makes it easy to manage your store’s inventory by scanning product barcodes, storing product details, and tracking sales. Follow the steps below to get started!',
              style: normalTextStyle12,
            ),
            24.0.sbH,
            _buildSection(
              title: '1. Scanning Product Codes',
              description:
                  'Use the built-in barcode scanner to quickly add products to your inventory:\n'
                  '- Tap the "Scan" button on the home screen to open the scanner.\n'
                  '- Point your device’s camera at the product’s barcode.\n'
                  '- The app automatically fetches product details (like name, category, and image) from an external database if available.\n'
                  '- If no details are found, you can capture an image of the product and manually enter details like price, quantity, and expiry date.\n'
                  '- Once scanned, the product is ready to be saved to your store’s inventory.',
              icon: SvgAssets.scan,
            ),
            16.0.sbH,
            _buildSection(
              title: '2. Storing Products in Inventory',
              description: 'Manage your store’s inventory with ease:\n'
                  '- After scanning or manually entering product details, save the product to your store.\n'
                  '- The app checks for duplicates to prevent adding the same product twice.\n'
                  '- View all products in the "Product List" section, where you can filter by all products, expiring items, or low stock.\n'
                  '- Each product includes details like price, cost price, quantity, and expiry date, helping you keep track of your inventory.\n'
                  '- Receive alerts for low stock (quantity ≤ 5) or expiring products (within 30 days) to stay proactive.',
              icon: SvgAssets.records,
            ),
            16.0.sbH,
            _buildSection(
              title: '3. Selling from Your Store',
              description: 'Track and manage sales effortlessly:\n'
                  '- Access product details to view stock levels and sales history.\n'
                  '- Update stock quantities when you sell products by editing the product or using the restock feature.\n'
                  '- Monitor your inventory summary, including total stock, total cost, and total selling price, to understand your store’s performance.\n'
                  '- Use the product history to track actions like product creation, updates, or restocking, ensuring full visibility of your sales process.\n'
                  '- Restock low inventory by adding more units directly from the product details page.',
              icon: SvgAssets.newSupplier,
            ),
            24.0.sbH,
            AppText(
              'Get Started Now!',
              style: bodyMedium,
            ),
            8.0.sbH,
            AppText(
              'Start scanning products, managing your inventory, and tracking sales today. Tap the "Scan" button on the home screen to add your first product!',
              style: normalTextStyle12,
            ),
            16.0.sbH,
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorValues.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const AppText(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
              ),
              8.0.sbW,
              Expanded(
                child: AppText(
                  title,
                  style: bodyMedium,
                ),
              ),
            ],
          ),
          8.0.sbH,
          AppText(
            description,
            style: normalTextStyle12,
          ),
        ],
      ),
    );
  }
}
