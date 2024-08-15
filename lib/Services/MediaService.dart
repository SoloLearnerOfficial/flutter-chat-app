import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  MediaService();
  Future<File?> pickImage() async {
    try {
      XFile? _file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (_file != null) {
        return File(_file.path);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
