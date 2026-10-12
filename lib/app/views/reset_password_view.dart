import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/message_service.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final newPasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;

  Future<void> _updatePassword() async {
    final password = newPasswordController.text;
    if (password.length < 6) {
      MessageService.showError(
        title: 'Invalid',
        message: 'Password must be at least 6 characters long.',
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await SupabaseService.auth.updateUser(
        UserAttributes(password: password),
      );
      await MessageService.showSuccess(
        title: 'Success',
        message: 'Password updated successfully!',
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      MessageService.showError(
        title: 'Error',
        message: 'Failed to update password. Please try again.',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please enter your new password below.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: newPasswordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
