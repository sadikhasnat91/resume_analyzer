import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/upload_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }
    if (!Get.isRegistered<UploadController>()) {
      Get.put(UploadController(), permanent: true);
    }
    if (!Get.isRegistered<HistoryController>()) {
      Get.put(HistoryController(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }
}
