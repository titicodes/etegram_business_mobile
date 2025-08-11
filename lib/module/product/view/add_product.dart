import 'dart:async';
import 'dart:io';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app_widget/app_button.dart';
import '../../../app_widget/custom_appbar.dart';
import '../../../app_widget/input_fields.dart';
import '../../../base/base_ui.dart';
import '../../../constants/colors.dart';
import '../../../constants/reuseable.dart';
import '../../../constants/style.dart';
import '../../../core/model/product_model.dart';
import '../../../locator.dart';
import '../../../routes/routes.dart';
import '../../../service/local/drawer_service.dart';
import '../../../utils/snack_message.dart';
import '../../home/drawer/nav_drawer.dart';
import '../vm/product_viewmodel.dart';

class AddProductView extends StatefulWidget {
  final bool isEditing;
  final String? scannedCode;
  final Product? product;
  final String? ownerId;
  final String? storeId;
  final Product? externalProduct;
  final bool needsImageSelection;
  final bool hasMissingFields;

  const AddProductView({
    super.key,
    required this.isEditing,
    this.scannedCode,
    this.product,
    this.ownerId,
    this.storeId,
    this.externalProduct,
    this.needsImageSelection = false,
    this.hasMissingFields = false,
  });

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView>
    with WidgetsBindingObserver {
  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAppPaused = false;

  // Controllers and focus nodes for decimal fields
  final _costPriceIntegerController = TextEditingController();
  final _costPriceDecimalController = TextEditingController();
  final _sellingPriceIntegerController = TextEditingController();
  final _sellingPriceDecimalController = TextEditingController();
  final _costPriceIntegerFocusNode = FocusNode();
  final _costPriceDecimalFocusNode = FocusNode();
  final _sellingPriceIntegerFocusNode = FocusNode();
  final _sellingPriceDecimalFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();
  final _minQuantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final model = locator<ProductViewModel>();
    if (model.selectedImage != null && model.selectedImage!.existsSync()) {
      _selectedImage.value = model.selectedImage;
      print(
          'AddProductView: Initialized with existing image: ${model.selectedImage!.path}');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isAppPaused = state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive;
    });
    print('AddProductView: App lifecycle state changed to: $state');
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isAppPaused) {
      if (mounted) {
        showCustomToast('Cannot access camera while app is paused.',
            success: false, context: context);
      }
      return;
    }

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: SpinKitWave(
              size: 50.0,
              color: ColorValues.primaryColor,
            ),
          ),
        );
      }

      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (mounted) {
            Navigator.pop(context);
            showCustomToast(
              'Camera permission denied. Please enable it in settings.',
              success: false,
              context: context,
            );
            if (status.isPermanentlyDenied) {
              await openAppSettings();
            }
          }
          return;
        }
      } else {
        status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (mounted) {
            Navigator.pop(context);
            showCustomToast(
              'Gallery permission denied. Please enable it in settings.',
              success: false,
              context: context,
            );
            if (status.isPermanentlyDenied) {
              await openAppSettings();
            }
          }
          return;
        }
      }

      final model = locator<ProductViewModel>();
      await model.pickImage(context, source: source);

      if (mounted) {
        Navigator.pop(context);
        if (model.selectedImage != null &&
            await model.selectedImage!.exists()) {
          _selectedImage.value = model.selectedImage;
          print('AddProductView: Image selected: ${model.selectedImage!.path}');
        } else {
          print(
              'AddProductView: No valid image selected from ProductViewModel');
          showCustomToast('Failed to select image.',
              success: false, context: context);
        }
      }
    } catch (e, stackTrace) {
      print('AddProductView: Error picking image: $e\n$stackTrace');
      if (mounted) {
        Navigator.pop(context);
        showCustomToast('Failed to select image: $e',
            success: false, context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerService = locator<DrawerService>();
    return BaseView<ProductViewModel>(
      onModelReady: (model) {
        drawerService.setScaffoldKey(scaffoldKey);
        print('AddProductView: Model ready, instance: ${model.hashCode}');
        if (!widget.isEditing && widget.product == null) {
          model.clearControllers();
          if (widget.scannedCode != null && widget.externalProduct != null) {
            print(
                'AddProductView: Populating with external product, barcode: ${widget.scannedCode}');
            model.populateControllers(widget.externalProduct!);
            model.productImageUrl = widget.externalProduct!.imageUrl;
            // Initialize decimal controllers
            if (model.costPriceController.text.isNotEmpty) {
              final parts = model.costPriceController.text.split('.');
              _costPriceIntegerController.text = parts[0];
              _costPriceDecimalController.text =
                  parts.length > 1 ? parts[1] : '00';
            }
            if (model.priceController.text.isNotEmpty) {
              final parts = model.priceController.text.split('.');
              _sellingPriceIntegerController.text = parts[0];
              _sellingPriceDecimalController.text =
                  parts.length > 1 ? parts[1] : '00';
            }
          } else if (widget.scannedCode != null) {
            print('AddProductView: Setting barcode: ${widget.scannedCode}');
            model.codeController.text = widget.scannedCode!;
            model.categoryController.text = 'Uncategorized';
            model.priceController.text = '1.00';
            model.costPriceController.text = '0.00';
            model.quantityController.text = '1';
            model.minQuantityController.text = '1';
            model.totalValue.value = '1.00'; // Initialize totalValue
            model.productImageUrl = null;
            // Initialize decimal controllers
            _sellingPriceIntegerController.text = '1';
            _sellingPriceDecimalController.text = '00';
            _costPriceIntegerController.text = '0';
            _costPriceDecimalController.text = '00';
          }
        } else if (widget.isEditing && widget.product != null) {
          print(
              'AddProductView: Populating with existing product: ${widget.product!.name}');
          model.populateControllers(widget.product!);
          model.productImageUrl = widget.product!.imageUrl;
          // Initialize decimal controllers
          if (model.costPriceController.text.isNotEmpty) {
            final parts = model.costPriceController.text.split('.');
            _costPriceIntegerController.text = parts[0];
            _costPriceDecimalController.text =
                parts.length > 1 ? parts[1] : '00';
          }
          if (model.priceController.text.isNotEmpty) {
            final parts = model.priceController.text.split('.');
            _sellingPriceIntegerController.text = parts[0];
            _sellingPriceDecimalController.text =
                parts.length > 1 ? parts[1] : '00';
          }
        }
        if (widget.hasMissingFields) {
          showCustomToast('Please fill in missing product details.',
              success: false, context: context);
        }
        if (model.selectedImage != null && model.selectedImage!.existsSync()) {
          _selectedImage.value = model.selectedImage;
          print(
              'AddProductView: Preserved existing image: ${model.selectedImage!.path}');
        }
        model.updateTotals();
      },
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            key: scaffoldKey,
            drawer: const NavDrawer(),
            backgroundColor: Colors.grey[100],
            appBar: CustomAppBar(
              title: widget.isEditing ? "Edit Product" : "Add Product",
              onBackPressed: () {
                print('AddProductView: Navigating back');
                navigationService.goBack();
              },
              showMenuIcon: true,
              onMenuPressed: () {
                print('AddProductView: Opening drawer');
                drawerService.openDrawer();
              },
              actions: [
                if (!widget.isEditing)
                  IconButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: () {
                      print(
                          'AddProductView: Navigating to addProductScannerRoute');
                      navigationService.navigateTo(addProductScannerRoute);
                    },
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
                      ValueListenableBuilder<File?>(
                        valueListenable: _selectedImage,
                        builder: (context, image, child) {
                          print(
                              'AddProductView: Building image widget, image: ${image?.path}, productImageUrl: ${model.productImageUrl}');
                          return Column(
                            children: [
                              if (model.productImageUrl != null &&
                                  model.productImageUrl!.isNotEmpty)
                                Image.network(
                                  model.productImageUrl!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        'AddProductView: Error loading network image: $error');
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 100,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              else if (image != null)
                                Image.file(
                                  image,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        'AddProductView: Error loading file image: $error');
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 100,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              else
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: widget.hasMissingFields ||
                                              widget.needsImageSelection
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (widget.hasMissingFields ||
                                  widget.needsImageSelection)
                                const Text(
                                  'Please select a product image',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              10.0.sbH,
                              AppButton(
                                text: 'Select Image from Gallery',
                                onTap: () => _pickImage(ImageSource.gallery),
                              ),
                              10.0.sbH,
                              AppButton(
                                text: 'Capture Image with Camera',
                                onTap: () => _pickImage(ImageSource.camera),
                              ),
                            ],
                          );
                        },
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Product Name",
                        controller: model.nameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Product name is required' : null,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Barcode",
                        controller: model.codeController,
                        readOnly:
                            widget.scannedCode != null || widget.isEditing,
                        validator: (value) =>
                            value!.isEmpty ? 'Barcode is required' : null,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Category",
                        controller: model.categoryController,
                        validator: (value) =>
                            value!.isEmpty ? 'Category is required' : null,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Size (Optional)",
                        controller: model.sizeController,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Brands (Optional)",
                        controller: model.brandsController,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Description (Optional)",
                        controller: model.descriptionController,
                        maxLines: 5,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      AppTextField(
                        hint: "Expiry Date (Optional)",
                        controller: model.expiryDateController,
                        readOnly: true,
                        onTap: () async {
                          await model.selectExpiryDate(context);
                        },
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: ColorValues.greyColor),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      20.0.sbH,
                      buildStepperField(
                        "Cost Price",
                        model.costPriceController,
                        model,
                        isDecimal: true,
                        hasError: widget.hasMissingFields &&
                            (model.costPriceController.text == '0.00' ||
                                model.costPriceController.text.isEmpty),
                        integerController: _costPriceIntegerController,
                        decimalController: _costPriceDecimalController,
                        integerFocusNode: _costPriceIntegerFocusNode,
                        decimalFocusNode: _costPriceDecimalFocusNode,
                      ),
                      20.0.sbH,
                      buildStepperField(
                        "Selling Price",
                        model.priceController,
                        model,
                        isDecimal: true,
                        hasError: widget.hasMissingFields &&
                            (model.priceController.text == '1.00' ||
                                model.priceController.text.isEmpty),
                        integerController: _sellingPriceIntegerController,
                        decimalController: _sellingPriceDecimalController,
                        integerFocusNode: _sellingPriceIntegerFocusNode,
                        decimalFocusNode: _sellingPriceDecimalFocusNode,
                      ),
                      20.0.sbH,
                      buildStepperField(
                        "Quantity",
                        model.quantityController,
                        model,
                        isDecimal: false,
                      ),
                      20.0.sbH,
                      buildStepperField(
                        "Minimum Quantity",
                        model.minQuantityController,
                        model,
                        isDecimal: false,
                        hasError: widget.hasMissingFields &&
                            model.minQuantityController.text.isEmpty,
                        quantityFocusNode: _minQuantityFocusNode,
                      ),
                      20.0.sbH,
                      ValueListenableBuilder<String>(
                        valueListenable: model.totalValue,
                        builder: (context, totalValue, child) {
                          print(
                              'AddProductView: Total value updated to $totalValue');
                          return Container(
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
                                  totalValue.isEmpty ? '0.00' : totalValue,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                onTap: () async {
                  print(
                      'AddProductView: Add/Update button pressed: ownerId=${widget.ownerId}, storeId=${widget.storeId}');
                  if (model.formKey.currentState!.validate()) {
                    if (widget.needsImageSelection &&
                        _selectedImage.value == null &&
                        (model.productImageUrl == null ||
                            model.productImageUrl!.isEmpty)) {
                      showCustomToast('Please select a product image.',
                          success: false, context: context);
                      return;
                    }
                    await model.saveOrUpdateProduct(
                      context: context,
                      isEditing: widget.isEditing,
                      existingProduct: widget.product,
                      scannedCode: widget.scannedCode,
                      ownerId: widget.ownerId,
                      storeId: widget.storeId,
                      selectedImage: _selectedImage.value,
                    );
                  } else {
                    showCustomToast('Please fill all required fields.',
                        success: false, context: context);
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
    String label,
    TextEditingController controller,
    ProductViewModel model, {
    bool isDecimal = false,
    bool hasError = false,
    TextEditingController? integerController,
    TextEditingController? decimalController,
    FocusNode? integerFocusNode,
    FocusNode? decimalFocusNode,
    FocusNode? quantityFocusNode,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        Timer? _debounce;

        void updateController({String? integer, String? decimal}) {
          if (isDecimal) {
            final intVal = integer ?? integerController!.text;
            final decVal = decimal ?? decimalController!.text;
            controller.text = (intVal.isEmpty && decVal.isEmpty)
                ? ''
                : '${intVal.isEmpty ? '0' : intVal}.${decVal.isEmpty ? '00' : decVal.padRight(2, '0')}';
            print(
                'AddProductView: Updated $label controller to ${controller.text}');
          } else {
            controller.text = integer ?? controller.text;
            print(
                'AddProductView: Updated $label controller to ${controller.text}');
          }
        }

        void debouncedUpdateTotals() {
          if (_debounce?.isActive ?? false) {
            _debounce?.cancel();
          }
          _debounce = Timer(const Duration(milliseconds: 500), () {
            print('AddProductView: Triggering updateTotals for $label');
            model.updateTotals();
          });
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: normalTextStyle),
            const SizedBox(width: 8.0),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorValues.whiteColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        border: hasError ? Border.all(color: Colors.red) : null,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove,
                            color: ColorValues.greyColor),
                        onPressed: () {
                          setState(() {
                            if (isDecimal) {
                              double currentValue = double.tryParse(
                                      '${integerController!.text.isEmpty ? '0' : integerController!.text}.${decimalController!.text.isEmpty ? '00' : decimalController!.text}') ??
                                  0.0;
                              if (currentValue > 0.0) {
                                currentValue -= 0.01;
                                final parts =
                                    currentValue.toStringAsFixed(2).split('.');
                                integerController!.text = parts[0];
                                decimalController!.text = parts[1];
                                updateController(
                                    integer: parts[0], decimal: parts[1]);
                                debouncedUpdateTotals();
                              }
                            } else {
                              int currentValue =
                                  int.tryParse(controller.text) ?? 0;
                              if (currentValue > 0) {
                                currentValue -= 1;
                                controller.text = currentValue.toString();
                                updateController(
                                    integer: currentValue.toString());
                                debouncedUpdateTotals();
                              }
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    isDecimal
                        ? Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  controller: integerController,
                                  focusNode: integerFocusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.zero,
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: ColorValues.whiteColor,
                                    errorText: hasError &&
                                            integerController!.text.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      print(
                                          'TextFormField: Integer changed to $value for $label');
                                      updateController(integer: value);
                                      debouncedUpdateTotals();
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    print(
                                        'TextFormField: Integer submitted for $label');
                                    FocusScope.of(context)
                                        .requestFocus(decimalFocusNode);
                                  },
                                ),
                              ),
                              const Text('.', style: TextStyle(fontSize: 20)),
                              SizedBox(
                                width: 40,
                                child: TextFormField(
                                  controller: decimalController,
                                  focusNode: decimalFocusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '00',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.zero,
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: ColorValues.whiteColor,
                                    errorText: hasError &&
                                            decimalController!.text.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      print(
                                          'TextFormField: Decimal changed to $value for $label');
                                      updateController(decimal: value);
                                      debouncedUpdateTotals();
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    print(
                                        'TextFormField: Decimal submitted for $label');
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: controller,
                              focusNode: quantityFocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: ColorValues.whiteColor,
                                errorText: hasError && controller.text.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  print(
                                      'TextFormField: Value changed to $value for $label');
                                  controller.text = value;
                                  debouncedUpdateTotals();
                                });
                              },
                              onFieldSubmitted: (_) {
                                print(
                                    'TextFormField: Value submitted for $label');
                                FocusScope.of(context).nextFocus();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '$label is required';
                                }
                                final parsed = int.tryParse(value);
                                if (parsed == null || parsed < 1) {
                                  return '$label must be ≥ 1';
                                }
                                return null;
                              },
                            ),
                          ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorValues.whiteColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        border: hasError ? Border.all(color: Colors.red) : null,
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.add, color: ColorValues.greyColor),
                        onPressed: () {
                          setState(() {
                            if (isDecimal) {
                              double currentValue = double.tryParse(
                                      '${integerController!.text.isEmpty ? '0' : integerController!.text}.${decimalController!.text.isEmpty ? '00' : decimalController!.text}') ??
                                  0.0;
                              currentValue += 0.01;
                              final parts =
                                  currentValue.toStringAsFixed(2).split('.');
                              integerController!.text = parts[0];
                              decimalController!.text = parts[1];
                              updateController(
                                  integer: parts[0], decimal: parts[1]);
                              debouncedUpdateTotals();
                            } else {
                              int currentValue =
                                  int.tryParse(controller.text) ?? 0;
                              currentValue += 1;
                              controller.text = currentValue.toString();
                              updateController(
                                  integer: currentValue.toString());
                              debouncedUpdateTotals();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    print('AddProductView: Disposing');
    _selectedImage.dispose();
    _costPriceIntegerController.dispose();
    _costPriceDecimalController.dispose();
    _sellingPriceIntegerController.dispose();
    _sellingPriceDecimalController.dispose();
    _costPriceIntegerFocusNode.dispose();
    _costPriceDecimalFocusNode.dispose();
    _sellingPriceIntegerFocusNode.dispose();
    _sellingPriceDecimalFocusNode.dispose();
    _quantityFocusNode.dispose();
    _minQuantityFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
