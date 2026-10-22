# Supabase Setup Guide

## Getting Your Supabase Credentials

### Step 1: Create a Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Enter the project name "AI Resume Analyzer" and a database password
5. Select your region and click "Create new project"
6. Wait for the project to initialize (2-3 minutes)

### Step 2: Get Your Credentials
1. Once created, go to Project Settings (bottom left gear icon)
2. Click "API" in the left sidebar
3. Copy your **Project URL** (e.g., `https://xxxxx.supabase.co`)
4. Copy your **anon public key** (the long string under "Project API keys")

### Step 3: Run the App with Credentials

**Option A: Command Line (Recommended)**
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Replace:
- `https://your-project.supabase.co` with your Project URL
- `your-anon-key` with your anon public key

**Option B: Set in ConfigService (For Development)**
Add this to your `main.dart` before `runApp()`:
```dart
import 'package:get/get.dart';
import 'app/services/config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set your Supabase credentials here for development
  final configService = Get.put(ConfigService());
  configService.setSupabaseCredentials(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );
  configService.printCurrentConfig();
  
  await SupabaseService.initialize();
  runApp(const ResumeAnalyzerApp());
}
```

### Step 4: Enable Email/Password Authentication

1. In your Supabase dashboard, go to **Authentication** (left sidebar)
2. Click on **Providers**
3. Find "Email" and enable it if not already enabled
4. Go to the "Email" settings and enable:
   - "Confirm email" (optional but recommended)
   - "Auto Confirm Users" (for testing without email confirmation)

### Troubleshooting

**Error: "Received an empty response with status code 404"**
- Your Supabase credentials are missing or invalid
- Make sure you passed `--dart-define` flags correctly
- Check that your Project URL starts with `https://`
- Verify your anon key is correct (should be a long string)

**Error: "Configuration issue"**
- You haven't provided Supabase credentials yet
- Follow Step 3 above to set them

**Sign up returns error**
- Make sure Email authentication is enabled in Supabase (Step 4)
- Check your database has auto-confirm enabled for easy testing
- Check Supabase project Activity tab for detailed error messages

## Console Debugging

When you run the app, check the debug console for:
```
=== Supabase Initialization ===
URL: https://your-project.supabase.co
Key: SET
Using env vars: true
✓ Supabase initialized successfully
```

If you see "NOT SET", your credentials are missing.
