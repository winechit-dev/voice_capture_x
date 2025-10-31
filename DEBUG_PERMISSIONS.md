# Debug Guide: Permission Issues

## Quick Fix Steps

### Step 1: Clean Build
```bash
cd /Users/nfqlocal/AndroidStudioProjects/voice_capture_x
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

### Step 2: Run with Debug Logs
```bash
flutter run --flavor development --target lib/main_development.dart
```

Watch the console for these debug messages:
- ✅ Microphone permission granted
- ✅ Speech-to-text initialized successfully
- ❌ Microphone permission denied
- ❌ Speech-to-text initialization failed

### Step 3: Grant Permissions

**When the app launches:**
1. You should see a permission dialog: **"Voice Capture X Would Like to Access the Microphone"**
   - **Tap "Allow"**

2. You might see a second dialog: **"Voice Capture X Would Like to Access Speech Recognition"**
   - **Tap "OK"**

### Step 4: If Permissions Were Denied

**Option A: Tap the Retry Button**
- Look for the gray button that says "Grant Permissions"
- Tap it to re-request permissions

**Option B: Reset Permissions (iOS)**
```bash
# For iOS Simulator
xcrun simctl privacy booted reset all com.example.voiceCaptureX.development

# Then restart the app
```

**Option C: Manually Enable in Settings (Physical Device)**
1. Open iPhone Settings
2. Scroll down to "Voice Capture X"
3. Enable:
   - ✅ Microphone
   - ✅ Speech Recognition
4. Force close and relaunch the app

## Troubleshooting

### Issue: "Permission denied" error immediately

**Possible Causes:**
1. Running on iOS Simulator without microphone support
2. Permissions were previously denied
3. Info.plist not properly configured

**Solutions:**
1. **Test on a physical device** (Simulators have limited microphone support)
2. Reset permissions (see Step 4 Option B above)
3. Verify Info.plist has both keys (run: `cat ios/Runner/Info.plist | grep -A 1 "NSMicrophone"`)

### Issue: Microphone works but no transcription

**This is expected if:**
- Internet connection is unavailable (speech recognition needs network)
- Speech recognition permission was denied

**Solution:**
- Ensure device has internet connection
- Check speech recognition permission in Settings

### Issue: Permission dialog never appears

**Possible Causes:**
1. Permissions already granted
2. App needs to be deleted and reinstalled
3. Info.plist missing permission descriptions

**Solutions:**
```bash
# Delete app from device/simulator, then:
flutter clean
flutter run
```

## Debug Log Examples

### ✅ Success Case:
```
✅ Microphone permission granted
🔊 Speech-to-text status: listening
✅ Speech-to-text initialized successfully
```

### ❌ Microphone Denied:
```
❌ Microphone permission denied
```
**Fix:** Tap "Grant Permissions" button or enable in Settings

### ❌ Speech Recognition Failed:
```
✅ Microphone permission granted
❌ Speech-to-text error: [error details]
❌ Speech-to-text initialization failed
```
**Fix:** Check internet connection and speech recognition permission

## Testing on Different Platforms

### iOS (Physical Device) - RECOMMENDED
```bash
flutter run -d [your-device-id]
```
- Full microphone support ✅
- Full speech recognition ✅
- Accurate permission handling ✅

### iOS Simulator
```bash
flutter run -d iPhone
```
- Limited microphone support ⚠️
- May not properly simulate permissions ⚠️
- **Use physical device for accurate testing**

### Android (Physical Device/Emulator)
```bash
flutter run -d [android-device-id]
```
- Full support on both physical and emulator ✅
- Microphone permission required
- Internet needed for speech recognition

## Quick Test Command

Run this complete test sequence:
```bash
#!/bin/bash
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Installing dependencies..."
flutter pub get

echo "🍎 Installing iOS pods..."
cd ios && pod install && cd ..

echo "🚀 Running app..."
flutter run --flavor development --target lib/main_development.dart

echo "✅ Watch console for permission debug logs!"
```

## Expected Behavior After Fix

1. **First Launch:**
   - App requests microphone permission → Tap "Allow"
   - App requests speech recognition → Tap "OK"
   - Button turns blue and becomes active

2. **After Granting Permissions:**
   - Status shows "Ready to Record"
   - Blue button is enabled
   - Can press and hold to record

3. **Recording:**
   - Button turns red
   - Status shows "Recording..."
   - Live transcription appears

4. **After Recording:**
   - Recording appears in list
   - Can tap to play
   - Transcription is visible

## Still Having Issues?

Check the console output and share:
1. The debug log messages (with ✅ or ❌)
2. Which platform you're testing on (iOS Simulator/Device, Android)
3. iOS version (Settings → General → About → iOS Version)
4. Any error messages from the console

## Common Simulator Issues

**iOS Simulator Limitations:**
- Microphone input is limited/simulated
- Speech recognition may not work properly
- Permission dialogs may behave differently

**Recommendation:** Always test recording features on a physical device for accurate results.
