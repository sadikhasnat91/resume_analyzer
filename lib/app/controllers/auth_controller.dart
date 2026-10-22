
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;
  final confirmPassword = ''.obs;

  final isLoading = false.obs;
  final isRecoveryMode = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  final SupabaseClient supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();

    _authSubscription = supabase.auth.onAuthStateChange.listen(
          (data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          isRecoveryMode.value = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.resetPassword);
          });
        }
      },
      onError: (error, stackTrace) {
        debugPrint('Auth state error: $error');
      },
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }

    final validEmail = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(value.trim());

    if (!validEmail) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password.value) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }

  void showMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }

  String authErrorMessage(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }

      if (message.contains('email not confirmed')) {
        return 'Please confirm your email before logging in.';
      }

      if (message.contains('rate limit') ||
          message.contains('too many requests')) {
        return 'Too many attempts. Please wait and try again.';
      }

      if (message.contains('expired') ||
          message.contains('invalid otp') ||
          message.contains('token has expired')) {
        return 'This recovery link may have expired. Request a new link.';
      }

      return error.message;
    }

    debugPrint('Authentication error: $error');
    return 'Connection failed. Please check your internet and try again.';
  }

  // LOGIN
  Future<void> login() async {
    // LoginView must use this same form key.
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setLoading(true);

      await supabase.auth.signInWithPassword(
        email: email.value.trim(),
        password: password.value,
      );

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      showMessage('Login Failed', authErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }

  // SIGNUP: create account, then go to Login.
  Future<void> signup() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setLoading(true);

      final response = await supabase.auth.signUp(
        email: email.value.trim(),
        password: password.value,
        data: {
          'full_name': name.value.trim(),
        },
      );

      if (response.user == null) {
        showMessage(
          'Signup Failed',
          'Unable to create your account. Please try again.',
        );
        return;
      }

      // If Supabase creates a session automatically, sign it out.
      // The user must log in manually after signup.
      if (response.session != null) {
        await supabase.auth.signOut();
      }

      password.value = '';
      confirmPassword.value = '';

      if (response.session == null) {
        showMessage(
          'Verify Your Email',
          'Account created. Check your email to confirm your account, then log in.',
        );
      } else {
        showMessage(
          'Account Created',
          'Your account was created. Please log in with your email and password.',
        );
      }

      Get.offAllNamed(AppRoutes.login);
    } on AuthException catch (error) {
      final message = error.message.toLowerCase();

      if (message.contains('already registered') ||
          message.contains('already exists')) {
        showMessage(
          'Account Exists',
          'This email may already be registered. Please log in instead.',
        );
      } else {
        showMessage('Signup Failed', authErrorMessage(error));
      }
    } catch (error) {
      showMessage('Signup Failed', authErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }

  // SEND PASSWORD RESET LINK
  Future<void> sendPasswordResetEmail() async {
    final form = forgotPasswordFormKey.currentState;

    if (form == null) {
      showMessage('Email Required', 'Please enter your email address.');
      return;
    }

    if (!(form.validate())) {
      return;
    }

    form.save();
    final userEmail = email.value.trim();

    if (userEmail.isEmpty) {
      showMessage('Email Required', 'Please enter your email address.');
      return;
    }

    try {
      setLoading(true);

      await supabase.auth.resetPasswordForEmail(
        userEmail,
        redirectTo: Uri.base.origin,
      );

      Get.toNamed(
        AppRoutes.emailSent,
        arguments: userEmail,
      );
    } catch (error) {
      showMessage(
        'Unable to Send Reset Link',
        authErrorMessage(error),
      );
    } finally {
      setLoading(false);
    }
  }

  // UPDATE PASSWORD AFTER OPENING RECOVERY LINK
  Future<void> updateNewPassword() async {
    if (!isRecoveryMode.value) {
      showMessage(
        'Invalid Reset Session',
        'Please open the password reset link from your email again.',
      );
      return;
    }

    if (!(resetPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setLoading(true);

      await supabase.auth.updateUser(
        UserAttributes(password: password.value),
      );

      password.value = '';
      confirmPassword.value = '';
      isRecoveryMode.value = false;

      await supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      showMessage(
        'Password Updated',
        'Your password has been changed. Please log in with your new password.',
      );
    } catch (error) {
      showMessage(
        'Password Update Failed',
        authErrorMessage(error),
      );
    } finally {
      setLoading(false);
    }
  }

  // GO TO FORGOT PASSWORD PAGE
  void goToForgotPassword() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';

    forgotPasswordFormKey.currentState?.reset();

    Get.toNamed(AppRoutes.forgotPassword);
  }
}
