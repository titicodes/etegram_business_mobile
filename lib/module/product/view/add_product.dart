import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app_widget/app_button.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/style.dart';
import '../../../core/model/product_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/snack_message.dart';
import '../../../utils/widget_extension.dart';
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
    print(
        'AddProductView initState: scannedCode=${widget.scannedCode}, isEditing=${widget.isEditing}');
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ProductViewModel>(
      onModelReady: (model) {
        if (widget.scannedCode != null) {
          model.fetchProductDetailsFromAPI(widget.scannedCode!);
        } else if (widget.isEditing && widget.product != null) {
          model.populateControllers(widget.product!);
        } else {
          model.clearControllers();
        }
      },
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: CustomAppBar(
              title: widget.isEditing ? "Edit Product" : "Add Product",
              onBackPressed: () => navigationService.goBack(),
              showMenuIcon: false,
              actions: [
                if (!widget.isEditing)
                  IconButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: () =>
                        navigationService.navigateTo(addProductScannerRoute),
                  ),
              ],
            ),
            body: Form(
              key: model.formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (model.productImageUrl != null &&
                          model.productImageUrl!.isNotEmpty)
                        Image.network(
                          model.productImageUrl!,
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
                        controller: model.nameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Product name is required' : null,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Barcode (Optional)",
                        controller: model.codeController,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Category",
                        controller: model.categoryController,
                        validator: (value) =>
                            value!.isEmpty ? 'Category is required' : null,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Size (Optional)",
                        controller: model.sizeController,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Brands (Optional)",
                        controller: model.brandsController,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Description (Optional)",
                        controller: model.descriptionController,
                        maxLength: 3,
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Expiry Date (Optional)",
                        controller: model.expiryDateController,
                        readonly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            model.expiryDateController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: ColorValues.greyColor),
                      ),
                      20.0.sbH,
                      buildStepperField(
                          "Cost Price", model.costPriceController, model,
                          isDecimal: true),
                      20.0.sbH,
                      buildStepperField(
                          "Selling Price", model.priceController, model,
                          isDecimal: true),
                      20.0.sbH,
                      buildStepperField(
                          "Quantity", model.quantityController, model),
                      20.0.sbH,
                      buildStepperField("Minimum Quantity",
                          model.minQuantityController, model),
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
                              model.getTotalValue(),
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
                isLoading: model.isLoading.value,
                onTap: () {
                  print(
                      'Add Product button pressed: ownerId=${widget.ownerId}, storeId=${widget.storeId}');
                  if (model.formKey.currentState!.validate()) {
                    if (widget.ownerId == null || widget.storeId == null) {
                      showCustomToast('Error: Owner or store not selected.');
                      return;
                    }
                    model.saveOrUpdateProduct(
                      context: context,
                      isEditing: widget.isEditing,
                      existingProduct: widget.product,
                      scannedCode: widget.scannedCode,
                      ownerId: widget.ownerId!,
                      storeId: widget.storeId!,
                    );
                  } else {
                    showCustomToast('Please fill all required fields.');
                  }
                },
              ),
            ),
          ),
          if (model.isFetchingExternalData.value || model.isLoading.value)
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

  Widget buildStepperField(
      String label, TextEditingController controller, ProductViewModel model,
      {bool isDecimal = false}) {
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
                    decoration: const BoxDecoration(
                      color: ColorValues.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove,
                          color: ColorValues.greyColor),
                      onPressed: () {
                        double currentValue =
                            double.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          setState(() {
                            currentValue -= isDecimal ? 0.01 : 1;
                            controller.text = isDecimal
                                ? currentValue.toStringAsFixed(2)
                                : currentValue.toInt().toString();
                            model.updateTotals();
                          });
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
                    decoration:
                        const BoxDecoration(color: ColorValues.whiteColor),
                    child: TextField(
                      controller: controller,
                      keyboardType: isDecimal
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
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
                          if (value.isEmpty ||
                              (isDecimal
                                  ? double.tryParse(value) == null
                                  : int.tryParse(value) == null)) {
                            controller.text = isDecimal ? "0.00" : "0";
                          }
                          model.updateTotals();
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
                    decoration: const BoxDecoration(
                      color: ColorValues.whiteColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: ColorValues.greyColor),
                      onPressed: () {
                        double currentValue =
                            double.tryParse(controller.text) ?? 0;
                        setState(() {
                          currentValue += isDecimal ? 0.01 : 1;
                          controller.text = isDecimal
                              ? currentValue.toStringAsFixed(2)
                              : currentValue.toInt().toString();
                          model.updateTotals();
                        });
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
