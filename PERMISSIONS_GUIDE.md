# Permissions Guide

## Overview

The Voice Capture X app requires two critical permissions to function:
1. **Microphone** - To record audio
2. **Speech Recognition** - To transcribe voice to text

## Permission Flow

### First Launch
When you first launch the app, it will automatically request permissions:

1. **Microphone Permission** dialog appears
   - Tap **Allow** to grant access

2. **Speech Recognition Permission** dialog appears (iOS)
   - Tap **Allow** to grant access

### If Permissions Denied

If you deny permissions, the app will show:

- **Error message** at the top with details
- **Grayed-out button** with "Grant Permissions" text
- **Retry action** in the error snackbar

## How to Grant Permissions

### Option 1: Tap the Button
Simply tap the gray "Grant Permissions" button to re-trigger the permission request.

### Option 2: Via Snackbar
When the error appears, tap the **Retry** button in the red snackbar.

### Option 3: Via Settings (if permanently denied)

**iOS:**
1. Open iOS Settings app
2. Scroll down and find "Voice Capture X"
3. Toggle on **Microphone** and **Speech Recognition**
4. Return to the app and tap **Retry**

**Android:**
1. Open Android Settings
2. Go to Apps → Voice Capture X → Permissions
3. Enable **Microphone**
4. Return to the app and tap **Retry**

## Troubleshooting

### "Permission not granted" error persists

**Solution:**
1. Completely close the app (swipe away from multitasking)
2. Open Settings and verify permissions are enabled
3. Relaunch the app
4. Tap the **Grant Permissions** button

### Permissions granted but still not working

**iOS Specific:**
1. Verify deployment target is iOS 13.0+ (already configured)
2. Check that Info.plist contains:
   - `NSMicrophoneUsageDescription`
   - `NSSpeechRecognitionUsageDescription`
3. Rebuild the app: `flutter clean && flutter run`

**Android Specific:**
1. Verify AndroidManifest.xml contains:
   - `RECORD_AUDIO` permission
   - `INTERNET` permission (for cloud speech recognition)
2. Rebuild the app: `flutter clean && flutter run`

### Testing Permissions

**Test Scenarios:**
1. ✅ Grant both permissions → App works normally
2. ✅ Deny microphone → Shows error, button disabled
3. ✅ Deny speech recognition → Shows error, can record but no transcription
4. ✅ Tap retry after denying → Re-requests permissions
5. ✅ Grant permissions late → App initializes and works

## Technical Details

### Permission Checking Flow

```dart
1. App launches
2. VoiceCaptureCubit._init() called
3. AudioService.initializeSpeechToText() checks permissions
4. If denied:
   - State set to error
   - UI shows retry option
   - Button disabled
5. If granted:
   - Speech-to-text initialized
   - Ready to record
```

### Code Locations

- **Permission requests:** `lib/services/audio_service.dart` (lines 35-51)
- **Error handling:** `lib/voice_capture/cubit/voice_capture_cubit.dart` (lines 24-66)
- **UI feedback:** `lib/voice_capture/view/voice_capture_page.dart` (lines 39-62)

### Platform-Specific Configuration

**iOS:** `ios/Runner/Info.plist`
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to transcribe your voice recordings.</string>
```

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

**macOS:** `macos/Runner/DebugProfile.entitlements` & `Release.entitlements`
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

## Best Practices

1. **Always test on physical devices** - Simulators may not properly test permissions
2. **Test both grant and deny scenarios** - Ensure UI handles both cases
3. **Provide clear feedback** - Users should always know why something isn't working
4. **Make retry easy** - One-tap to retry permissions
5. **Never silently fail** - Always show why something didn't work

## Common Issues

### Issue: "Microphone permission not granted" on first launch
**Cause:** Permission dialog was dismissed or denied
**Fix:** Tap the "Grant Permissions" button or "Retry" in snackbar

### Issue: Recording works but no transcription
**Cause:** Speech recognition permission denied or internet unavailable
**Fix:** Grant speech permission and ensure internet connection

### Issue: Button stays gray after granting permissions
**Cause:** App state not updated after permission grant
**Fix:** Tap the button to retry initialization

### Issue: Permissions prompt never appears
**Cause:** Info.plist/AndroidManifest not properly configured
**Fix:** Verify platform-specific configuration files, rebuild app

## Development Notes

- Permissions are requested lazily (on first use)
- Permission state is checked on every recording attempt
- Speech-to-text requires internet for cloud recognition
- Microphone access is required for both recording and transcription
- iOS requires both microphone and speech recognition permissions
- Android primarily needs microphone permission

## Support

If you continue experiencing permission issues:
1. Check that you're running on iOS 13.0+ or Android 6.0+
2. Verify the app has been rebuilt after configuration changes
3. Check device settings to ensure permissions aren't restricted at system level
4. Review console logs for specific error messages
