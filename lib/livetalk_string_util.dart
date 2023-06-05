extension ExtensionString on String {
  bool get isValidMobilePhone {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (length == 0) {
      return false;
    }
    if (!regExp.hasMatch(this)) {
      return false;
    }
    return true;
  }
}