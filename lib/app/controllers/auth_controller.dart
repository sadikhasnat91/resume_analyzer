import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';
import '../services/supabase_service.dart';
import '../services/message_service.dart';
import 'dashboard_controller.dart';
import 'history_controller.dart';

class AuthController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Moved to main.dart for reliable interception before widget tree mounts
  }

  Future<void> login() async {
    if (loginFormKey.currentState?.validate() ?? false) {
      if (!SupabaseService.isConfigured) {
        await MessageService.showError(
          title: 'Configuration Error',
          message: 'Supabase is not configured. Please check your credentials.',
          showRetry: true,
          onRetry: login,
        );
        return;
      }

      try {
        isLoading.value = true;

        final response = await SupabaseService.auth.signInWithPassword(
          email: email.value.trim(),
          password: password.value.trim(),
        );

        if (response.session == null) {
          throw AuthException(
            'Unable to sign in. Please verify your credentials.',
          );
        }

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changePage(0);
        }

        if (Get.isRegistered<HistoryController>()) {
          Get.find<HistoryController>().fetchHistory();
        }

        await MessageService.showSuccess(
          title: 'Login Successful',
          message: 'Welcome back! Redirecting to home...',
          onConfirm: () => Get.offAllNamed(AppRoutes.dashboard),
        );
      } on AuthException catch (e) {
        await MessageService.showError(
          title: 'Login Failed',
          message: _authErrorMessage(e),
          showRetry: true,
          onRetry: login,
        );
      } on Exception catch (e) {
        await MessageService.showError(
          title: 'Login Failed',
          message: _authErrorMessage(e),
          showRetry: true,
          onRetry: login,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> signup() async {
    if (signupFormKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        if (!SupabaseService.isConfigured) {
          await MessageService.showError(
            title: 'Configuration Error',
            message:
                'Supabase is not configured. Please check your credentials.',
            showRetry: true,
            onRetry: signup,
          );
          return;
        }

        final response = await SupabaseService.auth.signUp(
          email: email.value.trim(),
          password: password.value.trim(),
          data: {'full_name': name.value.trim()},
        );

        if (response.user != null) {
          if (response.session == null) {
            await MessageService.showInfo(
              title: 'Verification Required',
              message:
                  'Account created successfully. Check your email to confirm your account before logging in.',
              icon: Icons.mail_outline,
              iconColor: const Color(0xFF2196F3),
            );
          } else {
            await MessageService.showSuccess(
              title: 'Account Created',
              message:
                  'Your account has been created successfully! Please log in.',
              onConfirm: () => Get.offAllNamed(AppRoutes.login),
            );
          }
        } else {
          throw AuthException('Unable to create account. Please try again.');
        }
      } on AuthException catch (e) {
        await MessageService.showError(
          title: 'Signup Failed',
          message: _authErrorMessage(e),
          showRetry: true,
          onRetry: signup,
        );
      } on Exception catch (e) {
        await MessageService.showError(
          title: 'Signup Failed',
          message: _authErrorMessage(e),
          showRetry: true,
          onRetry: signup,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> forgotPassword() async {
    final emailValue = email.value.trim();
    if (emailValue.isEmpty || !GetUtils.isEmail(emailValue)) {
      await MessageService.showError(
        title: 'Invalid Email',
        message: 'Please enter a valid email address in the email field first to reset your password.',
      );
      return;
    }

    try {
      isLoading.value = true;
      if (!SupabaseService.isConfigured) {
        await MessageService.showError(
          title: 'Configuration Error',
          message: 'Supabase is not configured. Please check your credentials.',
        );
        return;
      }

      await SupabaseService.auth.resetPasswordForEmail(emailValue);
      await MessageService.showSuccess(
        title: 'Password Reset',
        message: 'A password reset link has been sent to $emailValue. Please check your inbox.',
      );
    } on AuthException catch (e) {
      await MessageService.showError(
        title: 'Reset Failed',
        message: _authErrorMessage(e),
      );
    } catch (e) {
      await MessageService.showError(
        title: 'Reset Failed',
        message: _authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _authErrorMessage(Object error) {
    String msg = '';
    if (error is AuthException) {
      msg = error.message;
    } else {
      msg = error.toString();
    }

    final lowerMsg = msg.toLowerCase();

    if (lowerMsg.contains('invalid login credentials') ||
        lowerMsg.contains('invalid_credentials') ||
        lowerMsg.contains('invalid user credentials')) {
      return 'Incorrect email or password. Please check your credentials and try again.';
    }

    if (lowerMsg.contains('email not confirmed')) {
      return 'Your email address has not been confirmed. Please check your inbox for the verification link.';
    }

    if (lowerMsg.contains('user not found')) {
      return 'No account found with this email address.';
    }

    if (lowerMsg.contains('rate limit') || lowerMsg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (lowerMsg.contains('could not resolve host') ||
        lowerMsg.contains('xmlerrorrequest') ||
        lowerMsg.contains('networkerror') ||
        lowerMsg.contains('failed host lookup') ||
        lowerMsg.contains('socketexception')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    if (error is AuthException && error.message.isNotEmpty) {
      return error.message;
    }

    final cleanMsg = msg
        .replaceAll(RegExp(r'^AuthException\(message:\s*'), '')
        .replaceAll(RegExp(r', statusCode:.*$'), '')
        .replaceAll(RegExp(r'^Exception:\s*'), '');

    return cleanMsg.isNotEmpty
        ? cleanMsg
        : 'An unexpected authentication error occurred. Please try again.';
  }
}
