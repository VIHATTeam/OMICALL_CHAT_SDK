import 'dart:io';

extension ExtensionFile on File {
  double get fileSize {
    int sizeInBytes = lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }
}