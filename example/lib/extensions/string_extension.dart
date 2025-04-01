import 'package:path/path.dart' as p;

extension StringExtension on String {
  bool get isImage {
    final extension = p.extension(this);
    if (extension.isEmpty) {
      return false;
    }
    final type = extension.replaceAll(".", "").toLowerCase();
    if (type == "png" || type == "jpeg" || type == "jpg" || type == "heic") {
      return true;
    }
    return false;
  }

  bool get isVideo {
    final extension = p.extension(this);
    
    if (extension.isEmpty) {
      return false;
    }
    final type = extension.replaceAll(".", "").toLowerCase();
    if (type == "mp4" || type == 'mov') {
      return true;
    }
    return false;
  }

  bool get isAudio {
    final extension = p.extension(this);
    if (extension.isEmpty) {
      return false;
    }
    final type = extension.replaceAll(".", "").toLowerCase();
    if (type == "mp3" || type == "wav") {
      return true;
    }
    return false;
  }
}