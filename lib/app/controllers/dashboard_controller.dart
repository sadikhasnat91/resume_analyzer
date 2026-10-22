import 'package:get/get.dart';
import 'history_controller.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 0 || index == 2) {
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().fetchHistory();
      }
    }
  }
}
