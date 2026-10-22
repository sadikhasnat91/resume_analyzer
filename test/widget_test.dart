// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_resume_analyzer/app/routes/app_routes.dart';
import 'package:ai_resume_analyzer/app/views/login_view.dart';
import 'package:ai_resume_analyzer/main.dart';

void main() {
  testWidgets('Login screen displays title and button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ResumeAnalyzerApp(initialRoute: AppRoutes.login),
    );
    await tester.pumpAndSettle();

    expect(find.text('ResumeAI'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Login button opens dashboard without credentials or Supabase', (
    WidgetTester tester,
  ) async {
    Get.reset();

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: [
          GetPage(name: AppRoutes.login, page: () => const LoginView()),
          GetPage(
            name: AppRoutes.dashboard,
            page: () => const Scaffold(body: Text('Dashboard reached')),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Dashboard reached'), findsOneWidget);
  });
}
