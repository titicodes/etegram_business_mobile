import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

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

  const AddProductView({
    super.key,
    required this.isEditing,
    this.scannedCode,
    this.product,
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
          model.productImageUrl = ''; // Load image URL from local data if needed
          model.notifyListeners();
        } else {
          model.clearControllers(); // Clear fields if neither scannedCode nor product is available
        }
      },
      builder: (context, model, child) => Scaffold(
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
                    )
                  else
                    const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey),
                  20.0.sbH,
                  AppTextField(
                      hint: "Product Name", controller: model.nameController),
                  20.0.sbH,
                  AppTextField(hint: "Size", controller: model.sizeController),
                  20.0.sbH,
                  AppTextField(
                      hint: "Brand",
                      controller: model.brandController),
                  20.0.sbH,
                  AppTextField(
                      hint: "Category", controller: model.filterController),
                  20.0.sbH,
                  buildStepperField("Cost Price", model.costPriceController),
                  20.0.sbH,
                  buildStepperField("Selling Price", model.unitPriceController),
                  20.0.sbH,
                  buildStepperField("Quantity", model.quantityController),
                  20.0.sbH,
                  buildStepperField(
                      "Minimum Quantity", model.minQuantityController),
                  20.0.sbH,
                  buildStepperField("Stock", model.stockController),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: model.isFetchingExternalData
              ? const Center(child: CircularProgressIndicator())
              : AppButton(
            text: widget.isEditing ? "Update Product" : "Add Product",
            onTap: () => model.saveOrUpdateProduct(
                isEditing: widget.isEditing,
                existingProduct: widget.product,
                scannedCode: widget.scannedCode,
                context: context),
          ),
        ),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
