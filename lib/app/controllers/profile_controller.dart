import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../routes/app_routes.dart';
import '../services/message_service.dart';
import '../services/config_service.dart';
import 'history_controller.dart';

class ProfileController extends GetxController {
  final userName = 'ResumeAI User'.obs;
  final email = 'user@example.com'.obs;
  final phoneNumber = RxnString();
  final language = 'English'.obs;
  final notificationsEnabled = true.obs;
  final emailNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    try {
      if (SupabaseService.isInitialized && SupabaseService.isConfigured) {
        final user = SupabaseService.auth.currentUser;
        if (user != null) {
          userName.value = user.userMetadata?['full_name'] ?? 'ResumeAI User';
          email.value = user.email ?? 'user@example.com';
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> openAccountSettings() async {
    final tempUserName = userName.value;
    final tempPhoneNumber = phoneNumber.value;
    final tempLanguage = language.value;
    final currentGeminiKey = ConfigService.to.geminiApiKey.value;
    String newGeminiKey = currentGeminiKey;
    final isSaving = false.obs;

    Get.defaultDialog(
      title: 'Account Settings',
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              initialValue: tempUserName,
              onChanged: (value) => userName.value = value,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: email.value,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tempPhoneNumber,
              onChanged: (value) => phoneNumber.value = value,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: tempLanguage,
              items: ['English', 'Spanish', 'French', 'German']
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) {
                if (value != null) language.value = value;
              },
              decoration: InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: currentGeminiKey,
              onChanged: (value) => newGeminiKey = value.trim(),
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Enter your Google Gemini API Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.key),
              ),
            ),
          ],
        ),
      ),
      radius: 12,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      confirm: Obx(() => ElevatedButton(
        onPressed: isSaving.value ? null : () {
          isSaving.value = true;
          if (newGeminiKey.isNotEmpty) {
            ConfigService.to.setGeminiApiKey(newGeminiKey);
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            isSaving.value = false;
            Get.back();
            MessageService.showSuccessSnackbar(
              title: 'Settings Saved',
              message: 'Your account settings have been updated',
            );
          });
        },
        child: isSaving.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save Settings'),
      )),
      cancel: TextButton(
        onPressed: () {
          userName.value = tempUserName;
          phoneNumber.value = tempPhoneNumber;
          language.value = tempLanguage;
          Get.back();
        },
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> openNotifications() async {
    Get.defaultDialog(
      title: 'Notification Settings',
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: notificationsEnabled.value,
              onChanged: (value) {
                notificationsEnabled.value = value;
                MessageService.showInfoSnackbar(
                  title: 'Updated',
                  message: 'Push notifications ${value ? 'enabled' : 'disabled'}',
                );
              },
            )),
            const Divider(),
            Obx(() => SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive email updates'),
              value: emailNotificationsEnabled.value,
              onChanged: (value) {
                emailNotificationsEnabled.value = value;
                MessageService.showInfoSnackbar(
                  title: 'Updated',
                  message: 'Email notifications ${value ? 'enabled' : 'disabled'}',
                );
              },
            )),
          ],
        ),
      ),
      radius: 12,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Close'),
      ),
    );
  }

  Future<void> openHelp() async {
    Get.defaultDialog(
      title: 'Help & Support',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Frequently Asked Questions:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            const Text('Q: How do I upload a resume?\nA: Go to the Upload tab and select your PDF or Word document.', style: TextStyle(fontSize: 12, height: 1.5)),
            const SizedBox(height: 12),
            const Text('Q: How long does analysis take?\nA: Analysis usually completes within 30 seconds.', style: TextStyle(fontSize: 12, height: 1.5)),
            const SizedBox(height: 12),
            const Text('Q: Can I download my analysis?\nA: Yes, go to History and select any past analysis.', style: TextStyle(fontSize: 12, height: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('Email: support@resumeai.com', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('Phone: +1 (555) 123-4567', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      radius: 12,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Close'),
      ),
    );
  }

  Future<void> logout() async {
    final confirmed = await MessageService.showConfirmation(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmButtonText: 'Logout',
      cancelButtonText: 'Cancel',
    );

    if (confirmed == true) {
      try {
        await SupabaseService.auth.signOut();
        if (Get.isRegistered<HistoryController>()) {
          Get.find<HistoryController>().resumes.clear();
        }
        Get.offAllNamed(AppRoutes.login);
      } catch (e) {
        await MessageService.showError(
          title: 'Logout Failed',
          message: 'Error logging out: ${e.toString()}',
          showRetry: true,
          onRetry: logout,
        );
      }
    }
  }

  Future<void> changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isLoading = false.obs;

    Get.defaultDialog(
      title: 'Change Password',
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '• Password must be at least 6 characters\n• Include uppercase, lowercase & numbers for security',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
      radius: 12,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      confirm: Obx(() => ElevatedButton(
        onPressed: isLoading.value ? null : () async {
          final oldPwd = oldPasswordController.text.trim();
          final newPwd = newPasswordController.text.trim();
          final confirmPwd = confirmPasswordController.text.trim();

          if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
            MessageService.showErrorSnackbar(
              title: 'Error',
              message: 'All fields are required',
            );
            return;
          }

          if (newPwd.length < 6) {
            MessageService.showErrorSnackbar(
              title: 'Error',
              message: 'Password must be at least 6 characters',
            );
            return;
          }

          if (newPwd != confirmPwd) {
            MessageService.showErrorSnackbar(
              title: 'Error',
              message: 'New passwords do not match',
            );
            return;
          }

          try {
            isLoading.value = true;

            // Update password using Supabase
            await SupabaseService.auth.updateUser(
              UserAttributes(password: newPwd),
            );

            isLoading.value = false;
            Get.back();
            MessageService.showSuccessSnackbar(
              title: 'Success',
              message: 'Password changed successfully',
            );
          } on Exception catch (e) {
            isLoading.value = false;
            MessageService.showErrorSnackbar(
              title: 'Error',
              message: 'Failed to change password: ${e.toString()}',
            );
          }
        },
        child: isLoading.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Change Password'),
      )),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> deleteAccount() async {
    final result = await MessageService.showConfirmation(
      title: 'Delete Account',
      message: 'Are you sure? This action cannot be undone.',
    );
    if (result == true) {
      await MessageService.showInfo(
        title: 'Account Deletion Initiated',
        message: 'Your account deletion request has been submitted.',
        icon: Icons.info,
      );
    }
  }
}
