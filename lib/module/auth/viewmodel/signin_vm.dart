import 'package:dio/dio.dart';
import 'package:etegram_business/base/base_vm.dart';
import 'package:etegram_business/core/model/auth_response.dart';
import 'package:etegram_business/routes/routes.dart';
import 'package:flutter/material.dart';

import '../../../constants/reuseable.dart';
import '../../../locator.dart';


class SignInViewModel extends BaseViewModel {
  var emailNameController = TextEditingController();
  var passwordNameController = TextEditingController();

  final emailUnameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final FocusScopeNode focusNode = FocusScopeNode();
  final _showPassword = true;
  final _isLoading = false;
  var _isChecked = false;

  bool get showPassword => _showPassword;
  bool get isChecked => _isChecked;

  oncheckedChanged(bool val) {
    _isChecked = val;
    notifyListeners();
  }

  onChange() {
    formKey.currentState?.validate();
    notifyListeners();
  }

  goToHomeScreen() {
    navigationService.navigateTo(homeViewRoute);
  }

  goToMainNavScreen() {
    navigationService.navigateTo(mainNavViewRoute);
  }

  goToSignUpView(){
    navigationService.navigateTo(signUpScreenRoute);
  }
  
  goToForgetPasswordView(){
    navigationService.navigateTo(forgetPasswordRoute);
  }

  // @override
  // bool get isLoading => _isLoading;

  void toggleViewPassword() {
    _showPassword;
    notifyListeners();
  }

  void _clearLoginTextControllers() {
    emailUnameTextController.clear();
    passwordTextController.clear();
  }

  // Add the init() method here
  void init() {
    getUser();
    // For example, you might want to clear text controllers or
    // set initial values.
    emailNameController.clear();
    passwordNameController.clear();
  }

  submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    startLoader();
    try {
      var userData = Customer(
          email: emailNameController.text.trim(),
          password: passwordNameController.text.trim());

      var response = await authRepository.login(data: userData);

      if (response?.customer?.emailVerified == false) {
        stopLoader();
        notifyListeners();
        navigationService.navigateTo(verifyEmailView);
      } else if (response?.customer?.emailVerified == true) {
        notifyListeners();
        await getUser();
        print(response?.customer?.emailVerified);
        stopLoader();
      }
      stopLoader();
      notifyListeners();
    } on DioException {
      stopLoader();
      notifyListeners();
    }
  }



  getUser() async {
    startLoader();
    try {
      var response = await authRepository.getUser();
      notifyListeners();
      if (response?.id != null) {
        await userService.initializer();
        navigationService.navigateToAndRemoveUntil(dashboardRoute);
      }
      stopLoader();
    } catch (err) {
      print(err);
      stopLoader();
      notifyListeners();
    }
  }
}