import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileController extends GetxController {
  RxString userPhone = ''.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }
}
