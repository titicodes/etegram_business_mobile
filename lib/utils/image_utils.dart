import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/snack_message.dart';

class ImageUtils {
  static Future<(File?, String?)> pickAndCompressImage(BuildContext context, {required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) {
        showCustomToast('No image selected.', success: false);
        return (null, null);
      }

      print("Image picked: ${pickedFile.path}, name: ${pickedFile.name}");
      final file = File(pickedFile.path);
      final fileExtension = pickedFile.name.split('.').last.toLowerCase();
      final supportedFormats = ['jpeg', 'jpg', 'png', 'gif', 'webp', 'bmp'];

      if (!supportedFormats.contains(fileExtension)) {
        showCustomToast('Unsupported file format. Please use JPEG, PNG, GIF, WebP, or BMP.', success: false);
        return (null, null);
      }

      // Skip compression for GIF to preserve animations
      if (fileExtension == 'gif') {
        print("Skipping compression for GIF: ${file.path}");
        return (file, pickedFile.name);
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/profile_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final compressFormat = _getCompressFormat(fileExtension);

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: fileExtension == 'png' ? 85 : 70,
        minWidth: 800,
        minHeight: 800,
        format: compressFormat,
      );

      if (compressedFile != null) {
        final compressedFileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        print("Image compressed: ${compressedFile.path}, size: ${await compressedFile.length() / 1024} KB");
        return (File(compressedFile.path), compressedFileName);
      }
      showCustomToast('Failed to process image.', success: false);
      return (null, null);
    } catch (e) {
      print("Error processing image: $e");
      showCustomToast('Error processing image: $e', success: false);
      return (null, null);
    }
  }

  static CompressFormat _getCompressFormat(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      case 'jpeg':
      case 'jpg':
        return CompressFormat.jpeg;
      default:
        return CompressFormat.jpeg;
    }
  }

  static Future<void> showImageSourceDialog(BuildContext context, Function(BuildContext, {required ImageSource source}) pickImageCallback) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Image Source'),
        content: const Text('Choose where to pick your profile image from:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImageCallback(context, source: ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImageCallback(context, source: ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}