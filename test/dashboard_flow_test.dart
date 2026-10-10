import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_resume_analyzer/app/bindings/dashboard_binding.dart';
import 'package:ai_resume_analyzer/app/controllers/dashboard_controller.dart';
import 'package:ai_resume_analyzer/app/services/config_service.dart';
import 'package:ai_resume_analyzer/app/views/dashboard_view.dart';
import 'package:ai_resume_analyzer/app/routes/app_pages.dart';
import 'package:ai_resume_analyzer/app/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    Get.put(ConfigService());
  });

  tearDown(() {
    Get.reset();
  });

  test('DashboardController initializes with selectedIndex 0 (Home)', () {
    final controller = DashboardController();
    expect(controller.selectedIndex.value, 0);

    controller.changePage(1);
    expect(controller.selectedIndex.value, 1);
  });

  test('DashboardBinding registers all dashboard dependencies', () {
    final binding = DashboardBinding();
    binding.dependencies();

    expect(Get.isRegistered<DashboardController>(), isTrue);
    expect(Get.find<DashboardController>().selectedIndex.value, 0);
  });

  testWidgets('DashboardView builds cleanly without controller errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.dashboard,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Upload'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
