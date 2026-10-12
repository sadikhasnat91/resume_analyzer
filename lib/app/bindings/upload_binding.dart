import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class UploadBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UploadController>()) {
      Get.put(UploadController(), permanent: true);
    }
  }
}
