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

  String get encode {
    return Uri.encodeComponent(this);
  }

  String get decode {
    return Uri.decodeComponent(this);
  }
}