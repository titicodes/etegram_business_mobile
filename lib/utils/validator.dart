const emailRegex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
RegExp regEx = RegExp(r"(?=.*[a-z])(?=.*[0-9])\w+");

String? Function(String?)? emailValidator = (String? val) {
  String validate = val!.replaceAll(RegExp(r"\s+"), "");
  if (validate.isEmpty ||
      !RegExp(emailRegex).hasMatch(validate)) {
    return 'Enter valid email';
  }
  return null; // Return null for valid input
};

String? Function(String?)? passwordValidator = (String? val) {
  RegExp regEx = RegExp(r"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])\w+");
  if(val!.length<6){
    return "Enter a password of more than 6 characters";
  }else if(regEx.hasMatch(val)==false){
    return "Your Password must have a capital letter small letter and number";
  }
  return null;
};

String? Function(String?)? emptyValidator = (String? val) {
  String value = val??"";
  if(value.trim().isEmpty){
    return "value cannot be empty";
  }
  return null;
};