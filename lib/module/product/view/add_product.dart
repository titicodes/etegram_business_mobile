import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../app_widget/app_button.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/style.dart';
import '../../../core/model/product_model.dart';
import '../vm/product_viewmodel.dart';

class AddProductView extends StatefulWidget {
  final bool isEditing;
  final String? scannedCode;
  final Product? product;
  final String? ownerId;
  final String? storeId;

  const AddProductView({
    super.key,
    required this.isEditing,
    this.scannedCode,
    this.product,
    this.ownerId,
    this.storeId,
  });

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  @override
  void initState() {
    super.initState();
    print('AddProductView scannedCode: ${widget.scannedCode}'); // Debugging
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PRoductViewModel>(
      onModelReady: (model) {
        if (widget.scannedCode != null) {
          // Fetch product details using the barcode
          model.fetchProductDetailsFromAPI(widget.scannedCode!);
        } else if (widget.product != null) {
          // If editing, populate the fields with existing product data
          model.nameController.text = widget.product!.name ?? '';
          model.sizeController.text = widget.product!.size ?? '';
          model.brandController.text = widget.product!.brands ?? '';
          model.filterController.text = widget.product!.category ?? '';
          model.costPriceController.text = '${widget.product!.unitPrice ?? 0}';
          model.unitPriceController.text = '${widget.product!.unitPrice ?? 0}';
          model.quantityController.text = '${widget.product!.quantity ?? 1}';
          model.minQuantityController.text =
              '${widget.product!.minQuantity ?? 1}';
          model.stockController.text = '${widget.product!.stock ?? 0}';
          model.productImageUrl =
              ''; // Load image URL from local data if needed

          // Calculate totals after populating fields
          model.updateTotals();
          model.notifyListeners();
        } else {
          model
              .clearControllers(); // Clear fields if neither scannedCode nor product is available
        }
      },
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: CustomAppBar(
              title: widget.isEditing ? "Edit Product" : "Add Product",
              onBackPressed: () => Navigator.pop(context),
              showMenuIcon: false,
            ),
            body: Form(
              key: model.formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (model.productImageUrl.isNotEmpty)
                        Image.network(
                          model.productImageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  size: 100, color: Colors.grey),
                        )
                      else
                        const Icon(Icons.image_not_supported,
                            size: 100, color: Colors.grey),
                      20.0.sbH,
                      AppTextField(
                          hint: "Product Name",
                          controller: model.nameController),
                      20.0.sbH,
                      AppTextField(
                          hint: "Size", controller: model.sizeController),
                      20.0.sbH,
                      AppTextField(
                          hint: "Brand", controller: model.brandController),
                      20.0.sbH,
                      AppTextField(
                          hint: "Category", controller: model.filterController),
                      20.0.sbH,
                      buildStepperField(
                          "Cost Price", model.costPriceController),
                      20.0.sbH,
                      buildStepperField(
                          "Selling Price", model.unitPriceController),
                      20.0.sbH,
                      buildStepperField("Quantity", model.quantityController),
                      20.0.sbH,
                      buildStepperField(
                          "Minimum Quantity", model.minQuantityController),
                      20.0.sbH,
                      buildStepperField("Stock", model.stockController),
                      20.0.sbH,
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorValues.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Value", style: normalTextStyle),
                            Text(
                              model.totalValueController.text,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppButton(
                text: widget.isEditing ? "Update Product" : "Add Product",
                onTap: () {
                  print('Debug - Button pressed with:');
                  print('scannedCode: ${widget.scannedCode}');
                  print('ownerId: ${widget.ownerId}');
                  print('storeId: ${widget.storeId}');
                  model.saveOrUpdateProduct(
                    isEditing: widget.isEditing,
                    existingProduct: widget.product,
                    scannedCode: widget.scannedCode,
                    ownerId: widget.ownerId ?? '',
                    storeId: widget.storeId ?? '',
                    context: context,
                  );
                },
              ),
            ),
          ),
          if (model.isFetchingExternalData)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: SpinKitWave(
                  size: 50.0,
                  color: ColorValues.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Stepper Field for Quantity & Price Inputs
  Widget buildStepperField(String label, TextEditingController controller) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: normalTextStyle),
            const SizedBox(width: 10.0),
            Container(
              color: ColorValues.backgroundColor,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorValues.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove,
                          color: ColorValues.greyColor),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          setState(() =>
                              controller.text = (currentValue - 1).toString());
                        }
                        // No need to call updateTotals here as controller listeners will handle it
                      },
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: ColorValues.backgroundColor,
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(color: ColorValues.whiteColor),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty || int.tryParse(value) == null) {
                            controller.text = "0";
                          }
                        });
                        // No need to call updateTotals here as controller listeners will handle it
                      },
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: ColorValues.backgroundColor,
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorValues.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: ColorValues.greyColor),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        setState(() =>
                            controller.text = (currentValue + 1).toString());
                        // No need to call updateTotals here as controller listeners will handle it
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
