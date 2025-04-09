import 'dart:io';

import 'package:etegram_business/base/base_vm.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends BaseViewModel {
  bool isEdit = false;
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var userNameController = TextEditingController();
  var emailNameController = TextEditingController();

  String? selectedImage;
  File? selectedImageFile;

  bool showEdit = false;

  pickImage() {
    showEdit = !showEdit;
    notifyListeners();
  }

  selectImage({ImageSource source = ImageSource.camera}) async {
    pickImage();
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) {
      selectedImage = null;
      selectedImageFile = null;
    } else {
      var files = File(
        image.path.toString(),
      );
      selectedImageFile = files;
      selectedImage = image.path.toString();
    }
    notifyListeners();
  }

  init() {
    isEdit = false;
    // user = userService.user;
    //  firstNameController = TextEditingController(text: user.firstName??"");
    //  lastNameController = TextEditingController(text: user.lastName??"");
    //  userNameController = TextEditingController(text: user.username??"");
    //  emailNameController = TextEditingController(text: user.email??"");
    notifyListeners();
  }

  changeEdit() {
    isEdit = !isEdit;
    notifyListeners();
  }
}
