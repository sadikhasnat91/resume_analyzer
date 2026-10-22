
import 'package:get/get.dart';

import '../bindings/dashboard_binding.dart';
import '../bindings/upload_binding.dart';

import '../views/analysis_view.dart';
import '../views/dashboard_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/splash_view.dart';
import '../views/upload_view.dart';
import '../views/forgot_password_view.dart';
import '../views/email_sent_view.dart';
import '../views/reset_password_view.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),

    // Login page
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),

    // Signup page - Already registered
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
    ),

    // Dashboard page
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // Upload page
    GetPage(
      name: AppRoutes.upload,
      page: () => const UploadView(),
      binding: UploadBinding(),
    ),

    // Analysis page
    GetPage(
      name: AppRoutes.analysis,
      page: () => const AnalysisView(),
    ),

    // Forgot password page
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),

    // Email sent page
    GetPage(
      name: AppRoutes.emailSent,
      page: () => const EmailSentView(),
    ),

    // Reset password page
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
    ),
  ];
}
