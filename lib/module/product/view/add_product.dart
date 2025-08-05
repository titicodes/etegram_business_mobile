//
//
// import 'package:etegram_business/utils/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/locator.dart';
// import 'package:etegram_business/service/local/user_service.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:etegram_business/app_widget/app_button.dart';
// import 'package:etegram_business/core/model/product_model.dart';
// import 'package:etegram_business/routes/routes.dart';
// import 'dart:io';
// import 'dart:async';
// import 'dart:isolate';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/app_widget/input_fields.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:etegram_business/module/home/drawer/nav_drawer.dart';
// import 'package:etegram_business/module/home/vm/home_vm.dart';
// import '../../../service/local/drawer_service.dart';
// import '../vm/product_viewmodel.dart';
//
// class AddProductView extends StatefulWidget {
//   final bool isEditing;
//   final String? scannedCode;
//   final Product? product;
//   final String? ownerId;
//   final String? storeId;
//   final Product? externalProduct;
//   final bool needsImageSelection;
//
//   const AddProductView({
//     super.key,
//     required this.isEditing,
//     this.scannedCode,
//     this.product,
//     this.ownerId,
//     this.storeId,
//     this.externalProduct,
//     this.needsImageSelection = false,
//   });
//
//   @override
//   State<AddProductView> createState() => _AddProductViewState();
// }
//
// class _AddProductViewState extends State<AddProductView> {
//   final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   Future<File?> _compressImage(File file) async {
//     try {
//       final receivePort = ReceivePort();
//       await Isolate.spawn(
//           _compressImageIsolate, [file.path, receivePort.sendPort]);
//       final compressedPath = await receivePort.first as String?;
//       return compressedPath != null ? File(compressedPath) : file;
//     } catch (e) {
//       print('AddProductView: Error compressing image: $e');
//       showCustomToast('Failed to compress image.',
//           success: false, context: context);
//       return file;
//     }
//   }
//
//   static void _compressImageIsolate(List<dynamic> args) async {
//     final path = args[0] as String;
//     final sendPort = args[1] as SendPort;
//     try {
//       final compressedFile = await FlutterImageCompress.compressAndGetFile(
//         path,
//         "${path}_compressed.jpg",
//         quality: 70,
//         minWidth: 800,
//         minHeight: 800,
//       );
//       sendPort.send(compressedFile?.path);
//     } catch (e) {
//       sendPort.send(null);
//     }
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     PermissionStatus status;
//
//     if (source == ImageSource.camera) {
//       status = await Permission.camera.request();
//       if (status.isDenied || status.isPermanentlyDenied) {
//         showCustomToast(
//             'Camera permission denied. Please enable it in settings.',
//             success: false,
//             context: context);
//         if (status.isPermanentlyDenied) {
//           openAppSettings();
//         }
//         return;
//       }
//     } else {
//       status = await Permission.photos.request();
//       if (status.isDenied || status.isPermanentlyDenied) {
//         showCustomToast(
//             'Gallery permission denied. Please enable it in settings.',
//             success: false,
//             context: context);
//         if (status.isPermanentlyDenied) {
//           openAppSettings();
//         }
//         return;
//       }
//     }
//
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: source,
//       maxHeight: 800,
//       maxWidth: 800,
//       imageQuality: 70,
//     );
//     if (pickedFile != null && mounted) {
//       final compressed = await _compressImage(File(pickedFile.path));
//       if (mounted) {
//         _selectedImage.value = compressed;
//         locator<ProductViewModel>().productImageUrl =
//             null; // Clear remote image
//       }
//     } else {
//       showCustomToast('Image selection cancelled.',
//           success: false, context: context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final drawerService = locator<DrawerService>();
//     return BaseView<ProductViewModel>(
//       onModelReady: (model) {
//         drawerService.setScaffoldKey(scaffoldKey);
//         print('AddProductView: Model ready, instance: ${model.hashCode}');
//         if (widget.ownerId == null || widget.storeId == null) {
//           print('AddProductView: Missing ownerId or storeId');
//           showCustomToast('Error: Owner or store not selected.',
//               success: false, context: context);
//           Future.microtask(() => navigationService.goBack());
//           return;
//         }
//         if (!widget.isEditing && widget.product == null) {
//           model.clearControllers();
//           if (widget.scannedCode != null && widget.externalProduct != null) {
//             print(
//                 'AddProductView: Populating with external product, barcode: ${widget.scannedCode}');
//             model.populateControllers(widget.externalProduct!);
//             model.productImageUrl = widget.externalProduct!.imageUrl;
//             _selectedImage.value = null;
//           } else if (widget.scannedCode != null) {
//             print('AddProductView: Setting barcode: ${widget.scannedCode}');
//             model.codeController.text = widget.scannedCode!;
//             model.productImageUrl = null;
//             _selectedImage.value = null;
//           }
//         } else if (widget.isEditing && widget.product != null) {
//           print(
//               'AddProductView: Populating with existing product: ${widget.product!.name}');
//           model.populateControllers(widget.product!);
//           _selectedImage.value = null;
//         }
//         model.updateTotals();
//       },
//       builder: (context, model, child) => Stack(
//         children: [
//           Scaffold(
//             key: scaffoldKey,
//             drawer: const NavDrawer(),
//             backgroundColor: Colors.grey[100],
//             appBar: CustomAppBar(
//               title: widget.isEditing ? "Edit Product" : "Add Product",
//               onBackPressed: () {
//                 print('AddProductView: Navigating back');
//                 navigationService.goBack();
//               },
//               showMenuIcon: true,
//               onMenuPressed: () {
//                 print('AddProductView: Opening drawer');
//                 drawerService.openDrawer();
//               },
//               actions: [
//                 if (!widget.isEditing)
//                   IconButton(
//                     icon:
//                         const Icon(Icons.qr_code_scanner, color: Colors.white),
//                     onPressed: () {
//                       print(
//                           'AddProductView: Navigating to addProductScannerRoute');
//                       navigationService.navigateTo(addProductScannerRoute);
//                     },
//                   ),
//               ],
//             ),
//             body: Form(
//               key: model.formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       ValueListenableBuilder<File?>(
//                         valueListenable: _selectedImage,
//                         builder: (context, image, child) {
//                           return Column(
//                             children: [
//                               if (model.productImageUrl != null &&
//                                   model.productImageUrl!.isNotEmpty)
//                                 Image.network(
//                                   model.productImageUrl!,
//                                   height: 100,
//                                   width: 100,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(Icons.image_not_supported,
//                                           size: 100, color: Colors.grey),
//                                 )
//                               else if (image != null)
//                                 Image.file(
//                                   image,
//                                   height: 100,
//                                   width: 100,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(Icons.image_not_supported,
//                                           size: 100, color: Colors.grey),
//                                 )
//                               else
//                                 const Icon(Icons.image_not_supported,
//                                     size: 100, color: Colors.grey),
//                               10.0.sbH,
//                               AppButton(
//                                 text: 'Select Image from Gallery',
//                                 onTap: () => _pickImage(ImageSource.gallery),
//                               ),
//                               10.0.sbH,
//                               AppButton(
//                                 text: 'Capture Image with Camera',
//                                 onTap: () => _pickImage(ImageSource.camera),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Product Name",
//                         controller: model.nameController,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Product name is required' : null,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Barcode",
//                         controller: model.codeController,
//                         readOnly:
//                             widget.scannedCode != null || widget.isEditing,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Barcode is required' : null,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Category",
//                         controller: model.categoryController,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Category is required' : null,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Size (Optional)",
//                         controller: model.sizeController,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Brands (Optional)",
//                         controller: model.brandsController,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Description (Optional)",
//                         controller: model.descriptionController,
//                         maxLines: 5,
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       AppTextField(
//                         hint: "Expiry Date (Optional)",
//                         controller: model.expiryDateController,
//                         readOnly: true,
//                         onTap: () async {
//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime.now(),
//                             lastDate: DateTime(2100),
//                           );
//                           if (date != null && mounted) {
//                             model.expiryDateController.text =
//                                 DateFormat('dd MMM yyyy').format(date);
//                           }
//                         },
//                         suffixIcon: const Icon(Icons.calendar_today,
//                             color: ColorValues.greyColor),
//                         textInputAction: TextInputAction.next,
//                         onSubmitted: (_) => FocusScope.of(context).nextFocus(),
//                       ),
//                       20.0.sbH,
//                       buildStepperField(
//                           "Cost Price", model.costPriceController, model,
//                           isDecimal: true),
//                       20.0.sbH,
//                       buildStepperField(
//                           "Selling Price", model.priceController, model,
//                           isDecimal: true),
//                       20.0.sbH,
//                       buildStepperField(
//                           "Quantity", model.quantityController, model,
//                           isDecimal: false),
//                       20.0.sbH,
//                       buildStepperField("Minimum Quantity",
//                           model.minQuantityController, model,
//                           isDecimal: false),
//                       20.0.sbH,
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: ColorValues.whiteColor,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Total Value", style: normalTextStyle),
//                             Text(
//                               model.getTotalValue(),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             bottomNavigationBar: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: AppButton(
//                 text: widget.isEditing ? "Update Product" : "Add Product",
//                 isLoading: model.isLoading.value,
//                 onTap: () async {
//                   print(
//                       'AddProductView: Add/Update button pressed: ownerId=${widget.ownerId}, storeId=${widget.storeId}');
//                   if (model.formKey.currentState!.validate()) {
//                     if (widget.ownerId == null || widget.storeId == null) {
//                       showCustomToast('Error: Owner or store not selected.',
//                           success: false, context: context);
//                       return;
//                     }
//                     await model.saveOrUpdateProduct(
//                       context: context,
//                       isEditing: widget.isEditing,
//                       existingProduct: widget.product,
//                       scannedCode: widget.scannedCode,
//                       ownerId: widget.ownerId!,
//                       storeId: widget.storeId!,
//                       selectedImage: _selectedImage.value,
//                     );
//                     // Navigation is handled by ProductViewModel
//                   } else {
//                     showCustomToast('Please fill all required fields.',
//                         context: context);
//                   }
//                 },
//               ),
//             ),
//           ),
//           if (model.isFetchingExternalData.value || model.isLoading.value)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Center(
//                 child: SpinKitWave(
//                   size: 50.0,
//                   color: ColorValues.primaryColor,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildStepperField(
//       String label, TextEditingController controller, ProductViewModel model,
//       {bool isDecimal = false}) {
//     if (controller.text.isEmpty) {
//       controller.text = isDecimal ? "0.00" : "1";
//     }
//
//     return StatefulBuilder(
//       builder: (context, setState) => Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: normalTextStyle),
//           const SizedBox(width: 8.0),
//           Expanded(
//             child: Container(
//               color: Colors.transparent,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Container(
//                     width: 50,
//                     alignment: Alignment.center,
//                     decoration: const BoxDecoration(
//                       color: ColorValues.whiteColor,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         bottomLeft: Radius.circular(10),
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.remove,
//                           color: ColorValues.greyColor),
//                       onPressed: () {
//                         double currentValue =
//                             double.tryParse(controller.text) ??
//                                 (isDecimal ? 0.0 : 1.0);
//                         if (currentValue > (isDecimal ? 0.0 : 1.0)) {
//                           setState(() {
//                             currentValue -= isDecimal ? 0.01 : 1;
//                             controller.text = isDecimal
//                                 ? currentValue.toStringAsFixed(2)
//                                 : currentValue.toInt().toString();
//                             model.updateTotals();
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                   Container(
//                     width: 2,
//                     height: 40,
//                     color: Colors.grey[200],
//                   ),
//                   SizedBox(
//                     width: 100,
//                     child: TextFormField(
//                       controller: controller,
//                       keyboardType: isDecimal
//                           ? const TextInputType.numberWithOptions(decimal: true)
//                           : TextInputType.number,
//                       textAlign: TextAlign.center,
//                       textInputAction: TextInputAction.next,
//                       inputFormatters: [
//                         if (isDecimal)
//                           FilteringTextInputFormatter.allow(
//                               RegExp(r'^\d*\.?\d{0,2}'))
//                         else
//                           FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       decoration: InputDecoration(
//                         contentPadding:
//                             const EdgeInsets.symmetric(vertical: 10),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.zero,
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: ColorValues.whiteColor,
//                       ),
//                       onChanged: (value) {
//                         if (value.isEmpty) {
//                           setState(() {
//                             controller.text = isDecimal ? "0.00" : "1";
//                             model.updateTotals();
//                           });
//                         } else if (isDecimal) {
//                           final parsed = double.tryParse(value);
//                           if (parsed != null && parsed >= 0) {
//                             setState(() {
//                               controller.text = parsed.toStringAsFixed(2);
//                               model.updateTotals();
//                             });
//                           }
//                         } else {
//                           final parsed = int.tryParse(value);
//                           if (parsed != null && parsed >= 1) {
//                             setState(() {
//                               controller.text = parsed.toString();
//                               model.updateTotals();
//                             });
//                           }
//                         }
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return '$label is required';
//                         }
//                         if (isDecimal) {
//                           final parsed = double.tryParse(value);
//                           if (parsed == null || parsed < 0) {
//                             return '$label must be ≥ 0';
//                           }
//                         } else {
//                           final parsed = int.tryParse(value);
//                           if (parsed == null || parsed < 1) {
//                             return '$label must be ≥ 1';
//                           }
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   Container(
//                     width: 2,
//                     height: 40,
//                     color: Colors.grey[200],
//                   ),
//                   Container(
//                     width: 50,
//                     alignment: Alignment.center,
//                     decoration: const BoxDecoration(
//                       color: ColorValues.whiteColor,
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(10),
//                         bottomRight: Radius.circular(10),
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.add, color: ColorValues.greyColor),
//                       onPressed: () {
//                         setState(() {
//                           double currentValue =
//                               double.tryParse(controller.text) ??
//                                   (isDecimal ? 0.0 : 1.0);
//                           currentValue += isDecimal ? 0.01 : 1;
//                           controller.text = isDecimal
//                               ? currentValue.toStringAsFixed(2)
//                               : currentValue.toInt().toString();
//                           model.updateTotals();
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     print('AddProductView: Disposing');
//     _selectedImage.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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

class _AddProductViewState extends State<AddProductView> {
  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<File?> _persistImage(XFile pickedFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/product_image_$timestamp.jpg';
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(await pickedFile.readAsBytes());
      if (await targetFile.exists()) {
        print('AddProductView: Persisted image to: $targetPath');
        return targetFile;
      }

      final cacheDir = await getApplicationCacheDirectory();
      final fallbackPath = '${cacheDir.path}/product_image_$timestamp.jpg';
      final fallbackFile = File(fallbackPath);
      await fallbackFile.writeAsBytes(await pickedFile.readAsBytes());
      if (await fallbackFile.exists()) {
        print('AddProductView: Persisted image to fallback: $fallbackPath');
        return fallbackFile;
      }

      print(
          'AddProductView: Failed to persist image to both temp and cache directories');
      return null;
    } catch (e, stackTrace) {
      print('AddProductView: Error persisting image: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery && mounted) {
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
            if (source == ImageSource.gallery) Navigator.pop(context);
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

      if (source == ImageSource.camera) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxHeight: 600,
        maxWidth: 600,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        print('AddProductView: Image selection cancelled');
        if (mounted && source == ImageSource.gallery) {
          Navigator.pop(context);
        }
        if (mounted) {
          showCustomToast('Image selection cancelled.',
              success: false, context: context);
        }
        return;
      }

      final imageFile = await _persistImage(pickedFile);
      if (imageFile == null || !await imageFile.exists()) {
        print(
            'AddProductView: Persisted image file does not exist: ${pickedFile.path}');
        if (mounted && source == ImageSource.gallery) {
          Navigator.pop(context);
        }
        if (mounted) {
          showCustomToast('Selected image is invalid.',
              success: false, context: context);
        }
        return;
      }

      if (mounted) {
        _selectedImage.value = imageFile;
        locator<ProductViewModel>().productImageUrl = null;
        print('AddProductView: Image selected: ${imageFile.path}');
        if (source == ImageSource.gallery) {
          Navigator.pop(context);
        }
      }
    } catch (e, stackTrace) {
      print('AddProductView: Error picking image: $e\n$stackTrace');
      if (mounted && source == ImageSource.gallery) {
        Navigator.pop(context);
      }
      if (mounted) {
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
            _selectedImage.value = null;
          } else if (widget.scannedCode != null) {
            print('AddProductView: Setting barcode: ${widget.scannedCode}');
            model.codeController.text = widget.scannedCode!;
            model.productImageUrl = null;
            _selectedImage.value = null;
          }
        } else if (widget.isEditing && widget.product != null) {
          print(
              'AddProductView: Populating with existing product: ${widget.product!.name}');
          model.populateControllers(widget.product!);
          _selectedImage.value = null;
        }
        if (widget.hasMissingFields) {
          showCustomToast('Please fill in missing product details.',
              success: false, context: context);
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
                          return Column(
                            children: [
                              if (model.productImageUrl != null &&
                                  model.productImageUrl!.isNotEmpty)
                                Image.network(
                                  model.productImageUrl!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                )
                              else if (image != null)
                                Image.file(
                                  image,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                )
                              else
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: widget.hasMissingFields
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
                              if (widget.hasMissingFields)
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
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                model.expiryDateController.text.isNotEmpty
                                    ? DateTime.tryParse(
                                            model.expiryDateController.text) ??
                                        DateTime.now()
                                    : DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null && mounted) {
                            model.expiryDateController.text =
                                DateFormat('dd MMM yyyy').format(date);
                            model.updateTotals();
                          }
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
                      ),
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
                onTap: () async {
                  print(
                      'AddProductView: Add/Update button pressed: ownerId=${widget.ownerId}, storeId=${widget.storeId}');
                  if (model.formKey.currentState!.validate()) {
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
                        context: context);
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
  }) {
    if (controller.text.isEmpty) {
      controller.text = isDecimal ? "0.00" : "1";
    }

    return StatefulBuilder(
      builder: (context, setState) => Row(
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
                        double currentValue =
                            double.tryParse(controller.text) ??
                                (isDecimal ? 0.0 : 1.0);
                        if (currentValue > (isDecimal ? 0.0 : 1.0)) {
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
                    color: Colors.grey[200],
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: controller,
                      keyboardType: isDecimal
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        if (isDecimal)
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'))
                        else
                          FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: ColorValues.whiteColor,
                        errorText: hasError ? 'Please update $label' : null,
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            controller.text = isDecimal ? "0.00" : "1";
                            model.updateTotals();
                          });
                        } else if (isDecimal) {
                          final parsed = double.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            setState(() {
                              controller.text = parsed.toStringAsFixed(2);
                              model.updateTotals();
                            });
                          }
                        } else {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 1) {
                            setState(() {
                              controller.text = parsed.toString();
                              model.updateTotals();
                            });
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '$label is required';
                        }
                        if (isDecimal) {
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 0) {
                            return '$label must be ≥ 0';
                          }
                        } else {
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed < 1) {
                            return '$label must be ≥ 1';
                          }
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
                      icon: const Icon(Icons.add, color: ColorValues.greyColor),
                      onPressed: () {
                        setState(() {
                          double currentValue =
                              double.tryParse(controller.text) ??
                                  (isDecimal ? 0.0 : 1.0);
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('AddProductView: Disposing');
    _selectedImage.dispose();
    super.dispose();
  }
}
