import 'package:get/get.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/upload_binding.dart';
import '../views/analysis_view.dart';
import '../views/dashboard_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/splash_view.dart';
import '../views/upload_view.dart';
import '../views/reset_password_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.signup, page: () => const SignupView()),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.upload,
      page: () => const UploadView(),
      binding: UploadBinding(),
    ),
    GetPage(name: AppRoutes.analysis, page: () => const AnalysisView()),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
    ),
  ];
}
