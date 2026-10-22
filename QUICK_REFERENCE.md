# Quick Reference - Responsive Design API

## Responsive Class - Core Methods

```dart
// ===== SIZE DETECTION =====
Responsive.isMobilePortrait  // bool
Responsive.isTabletPortrait  // bool
Responsive.isTabletLandscape // bool
Responsive.isDesktop         // bool
Responsive.isLandscape       // bool
Responsive.isPortrait        // bool

// ===== SIZING =====
Responsive.screenWidth                     // double
Responsive.screenHeight                    // double
Responsive.blockSizeHorizontal             // 1% of width
Responsive.blockSizeVertical               // 1% of height

// ===== HELPERS =====
Responsive.responsiveFontSize(24)          // Scales font
Responsive.responsivePadding               // EdgeInsets
Responsive.responsivePaddingHorizontal     // EdgeInsets
Responsive.responsivePaddingVertical       // EdgeInsets
Responsive.responsiveBorderRadius          // double
Responsive.buttonHeight                    // double
Responsive.maxContentWidth                 // double
Responsive.gridCrossAxisCount              // int (1, 2, 3, or 4)
Responsive.getSafeHeight(context)          // double (without keyboard)
```

## Loading Indicators

```dart
// Full screen overlay
LoadingOverlay(
  isLoading: true,
  message: 'Loading...',
  child: MyWidget(),
)

// Spinner only
LoadingSpinner(
  size: 50,
  color: Colors.blue,
)

// Button indicator
LoadingButtonIndicator(
  size: 20,
  color: Colors.white,
)

// Dialog with spinner
DialogLoadingSpinner(
  title: 'Processing',
  message: 'Please wait...',
)
```

## Message Dialogs

```dart
// Success Dialog
SuccessDialog(
  title: 'Success!',
  message: 'Operation completed',
  onConfirm: () => {},
)

// Error Dialog
ErrorDialog(
  title: 'Error',
  message: 'Something went wrong',
  showRetry: true,
  onRetry: () => {},
)

// Info Dialog
InfoDialog(
  title: 'Info',
  message: 'Important information',
  icon: Icons.info_outline,
  iconColor: Colors.blue,
)
```

## Message Service

```dart
// Show Success
MessageService.showSuccess(
  title: 'Success',
  message: 'Done!',
  onConfirm: () => {},
)

// Show Error
MessageService.showError(
  title: 'Error',
  message: 'Failed',
  showRetry: true,
  onRetry: () => {},
)

// Show Info
MessageService.showInfo(
  title: 'Info',
  message: 'Note this',
)

// Quick Snackbars
MessageService.showSuccessSnackbar(title: 'Success')
MessageService.showErrorSnackbar(title: 'Error')
MessageService.showInfoSnackbar(title: 'Info')
MessageService.showWarningSnackbar(title: 'Warning')
```

## Responsive Builders

```dart
// Main Builder
ResponsiveBuilder(
  builder: (context, isDesktop, isTablet, isMobile) {
    // Your UI here
  },
)

// Layout Switch
ResponsiveLayout(
  desktopBody: DesktopWidget(),
  tabletBody: TabletWidget(),
  mobileBody: MobileWidget(),
)

// Responsive Container
ResponsiveContainer(
  padding: EdgeInsets.all(20),
  maxWidth: 800,
  child: MyWidget(),
)

// Responsive Grid
ResponsiveGridView(
  children: [Widget1(), Widget2()],
  childAspectRatio: 1.0,
)
```

## Common Patterns

### Responsive Text
```dart
Text(
  'Title',
  style: TextStyle(
    fontSize: Responsive.responsiveFontSize(24),
  ),
)
```

### Responsive Button
```dart
SizedBox(
  width: double.infinity,
  height: Responsive.buttonHeight,
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Submit'),
  ),
)
```

### Responsive Padding
```dart
Padding(
  padding: Responsive.responsivePadding,
  child: MyWidget(),
)
```

### Loading with Button
```dart
Obx(() => ElevatedButton(
  onPressed: controller.isLoading.value ? null : controller.submit,
  child: controller.isLoading.value
      ? const LoadingButtonIndicator()
      : const Text('Submit'),
))
```

### Full Screen Loading
```dart
LoadingOverlay(
  isLoading: controller.isLoading.value,
  message: 'Processing...',
  child: YourContent(),
)
```

## Device Sizes

| Device | Width | Height | Type |
|--------|-------|--------|------|
| Phone Portrait | 360-430 | 640-860 | Mobile |
| Phone Landscape | 640-860 | 360-430 | Mobile |
| Tablet Portrait | 600-768 | 1000-1366 | Tablet |
| Tablet Landscape | 1000-1366 | 600-768 | Tablet |
| Desktop | 1200+ | 800+ | Desktop |

## Colors

```dart
const primaryColor = Color(0xFF176D8D);    // Teal
const successColor = Color(0xFF4CAF50);    // Green
const errorColor = Color(0xFFF44336);      // Red
const infoColor = Color(0xFF2196F3);       // Blue
const bgColor = Color(0xFFE9F2F7);         // Light Blue
```

---

**Last Updated**: 2024
**Version**: 1.0
