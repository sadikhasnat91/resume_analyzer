import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/history_controller.dart';
import '../routes/app_routes.dart';
import '../services/gemini_service.dart';
import '../services/message_service.dart';
import '../services/resume_text_service.dart';

class UploadController extends GetxController {
  final selectedCategory = 'Software Engineering'.obs;
  final selectedSeniority = 'Senior'.obs;
  final isLoading = false.obs;
  final selectedFile = Rxn<PlatformFile>();
  final fileName = ''.obs;
  bool _isAnalyzing = false;

  final categories = <String>[
    'Software Engineering',
    'Data Science',
    'Product Management',
    'UX/UI Design',
    'Business Analysis',
    'DevOps',
    'Project Management',
  ].obs;

  final seniorities = <String>[
    'Intern',
    'Junior',
    'Mid',
    'Senior',
    'Lead',
    'Principal',
  ].obs;

  /// Pick a file from device
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        lockParentWindow: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          await MessageService.showError(
            title: 'File Too Large',
            message: 'Please select a PDF or Word file smaller than 5MB',
            showRetry: false,
          );
          return;
        }

        selectedFile.value = file;
        fileName.value = file.name;

        await MessageService.showSuccess(
          title: 'File Selected',
          message:
              'File: ${file.name}\nSize: ${(file.size / 1024).toStringAsFixed(2)} KB',
          confirmButtonText: 'Continue',
        );
      }
    } catch (e) {
      await MessageService.showError(
        title: 'File Pick Error',
        message: 'Error: ${e.toString()}',
        showRetry: true,
        onRetry: pickFile,
      );
    }
  }

  /// Analyze the selected resume
  Future<void> analyze() async {
    if (_isAnalyzing || isLoading.value) {
      return;
    }

    if (selectedFile.value == null) {
      await MessageService.showError(
        title: 'No File Selected',
        message: 'Please select a resume file to analyze',
        showRetry: false,
      );
      return;
    }

    _isAnalyzing = true;
    isLoading.value = true;

    try {
      final file = selectedFile.value!;
      final fileText = await ResumeTextService.extractText(file);

      final analysisResult = await GeminiService.analyzeResume(
        fileName: fileName.value,
        category: selectedCategory.value,
        seniority: selectedSeniority.value,
        resumeText: fileText,
        fileBytes: file.bytes,
        fileExtension: file.extension,
      );

      final historyController = Get.isRegistered<HistoryController>()
          ? Get.find<HistoryController>()
          : Get.put(HistoryController());
      await historyController.addResume(analysisResult);

      Get.toNamed(AppRoutes.analysis, arguments: analysisResult);
    } catch (e) {
      final isQuota = GeminiService.isQuotaExceededError(e);

      await MessageService.showError(
        title: isQuota ? 'Quota Exceeded' : 'Analysis Failed',
        message: GeminiService.friendlyErrorMessage(e),
        showRetry: false,
      );
    } finally {
      _isAnalyzing = false;
      isLoading.value = false;
    }
  }

  /// Clear selected file
  void clearFile() {
    selectedFile.value = null;
    fileName.value = '';
  }
}
