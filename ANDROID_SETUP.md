# Android Setup Guide

This document provides instructions for running the many-llm Flutter app on Android devices.

## Prerequisites

- Flutter SDK (version 3.38.0 or higher)
- Android Studio with Android SDK
- Java Development Kit (JDK) 17 or higher

## Android Configuration

The Android platform has been configured with the following settings:

### Build Configuration

- **Minimum SDK Version**: 21 (Android 5.0 Lollipop)
- **Target SDK Version**: Latest (configured via Flutter)
- **Java Version**: 17
- **Kotlin Version**: Latest (managed by Flutter)

### Permissions

The app requires the following permissions (configured in AndroidManifest.xml):

- `INTERNET`: Required for API calls to AI providers

### Application Details

- **Application ID**: `com.example.many_llm`
- **App Name**: AI Chat
- **Package**: `com.example.many_llm`

## Running the App

### 1. Connect an Android Device or Start an Emulator

#### Physical Device:
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect your device via USB
4. Verify connection: `flutter devices`

#### Android Emulator:
1. Open Android Studio
2. Go to Tools > Device Manager
3. Create a new virtual device or start an existing one
4. Verify emulator is running: `flutter devices`

### 2. Run the App

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on a specific device
flutter run -d <device-id>
```

## UI/Layout Optimizations for Android

The app includes several Android-specific UI optimizations:

### Responsive Design

- **Mobile Breakpoint**: < 768px (uses drawer navigation)
- **Desktop/Tablet**: ≥ 768px (uses sidebar navigation)

### Touch Targets

All interactive elements meet Android's minimum touch target size of 48dp:

- Buttons: 30x30 minimum with proper padding
- IconButtons: Configured with `minimumSize: Size(30, 30)`
- ListItems: Proper content padding for comfortable tapping

### Viewport Configuration

The web/index.html includes proper viewport meta tags for mobile devices:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
```

### SafeArea Implementation

- Main content wrapped in SafeArea to avoid notches and system UI
- Input area uses `SafeArea(top: false)` to properly handle keyboard insets
- Proper handling of system gesture areas and navigation bars

### Responsive Drawer

- Drawer width adapts to screen size: 85% of screen width
- Clamped between 280px and 380px for optimal UX
- Prevents overflow on small devices (e.g., 320px wide screens)

### Text and Layout

- All text uses proper overflow handling (ellipsis)
- Max-width constraints (800px) for content areas
- Proper text wrapping and line breaks
- Theme-aware colors and Material 3 styling

## Testing Different Screen Sizes

### Emulator Screen Sizes to Test

1. **Small Phone** (320x568, 4-inch): Test minimum supported size
2. **Standard Phone** (360x640, 5-inch): Most common Android size
3. **Large Phone** (412x915, 6.3-inch): Modern flagship size
4. **Tablet** (800x1280, 10-inch): Test desktop-like layout
5. **Foldable** (various): Test responsive breakpoints

### Testing Checklist

- [ ] Drawer opens and closes smoothly on mobile (<768px)
- [ ] Sidebar expands/collapses on tablet/desktop (≥768px)
- [ ] Chat messages display correctly with proper wrapping
- [ ] Input area doesn't overlap with keyboard
- [ ] Model selector dropdown displays properly
- [ ] All buttons are easily tappable (minimum 48dp)
- [ ] Text is readable without zooming
- [ ] No horizontal overflow or scrolling
- [ ] Landscape orientation works correctly
- [ ] Status bar and navigation bar don't cover content

## Troubleshooting

### Common Issues

#### 1. Gradle Build Fails

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 2. SDK Not Found

```bash
flutter config --android-sdk /path/to/android/sdk
flutter doctor --android-licenses
```

#### 3. Device Not Detected

```bash
adb kill-server
adb start-server
flutter devices
```

#### 4. Keyboard Overlaps Input

Ensure `android:windowSoftInputMode="adjustResize"` is set in AndroidManifest.xml (already configured).

### Performance Optimization

For better performance on Android:

1. Run in release mode: `flutter run --release`
2. Enable ProGuard for production builds
3. Use `--split-per-abi` for smaller APK sizes:
   ```bash
   flutter build apk --split-per-abi
   ```

## Building for Production

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
flutter build apk --release
```

### App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

**Note**: For release builds, you'll need to configure proper signing keys in `android/app/build.gradle.kts`.

## Additional Resources

- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/linux#android-setup)
- [Android Developer Documentation](https://developer.android.com/docs)
- [Material Design for Android](https://material.io/design/platform-guidance/android.html)
