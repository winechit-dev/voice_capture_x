# 🚀 Quick Start - Microphone Permission

## Run the App

```bash
cd /Users/nfqlocal/AndroidStudioProjects/voice_capture_x
flutter run
```

## What to Expect

### 1️⃣ App Launches
Console shows:
```
🎬 Initializing Voice Capture...
🎤 Requesting microphone permission...
```

### 2️⃣ Permission Dialog Appears
**"Voice Capture X Would Like to Access the Microphone"**

👉 **TAP "ALLOW"**

### 3️⃣ Permission Granted
Console shows:
```
✅ Microphone permission granted
🔊 Initializing speech-to-text...
✅ Speech-to-text initialized successfully
✅ Voice Capture initialized successfully
```

### 4️⃣ Ready to Use!
- Blue button activates
- Status shows "Ready to Record"
- Press and hold to record

## If You Denied Permission

### Gray Button Shows
- Text: "Grant Permissions"
- Mic icon is crossed out

### Error Message
"Microphone permission denied. Tap to try again."

### Fix It
**Option 1:** Tap the gray button → Permission dialog appears → Tap "Allow"

**Option 2:** Tap "Retry" in red error message

**Option 3:** Go to Settings → Voice Capture X → Enable Microphone

## Console Logs Reference

| Icon | Meaning |
|------|---------|
| 🎬 | App starting |
| 🎤 | Requesting permission |
| ✅ | Success |
| ❌ | Error/Denied |
| 🔊 | Speech-to-text activity |
| ⚠️ | Warning (non-critical) |
| 📱 | Opening settings |

## Test Commands

### Full Clean Build
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Delete App & Reset (Simulator)
```bash
xcrun simctl privacy booted reset all
flutter run
```

## Files Overview

| File | Purpose |
|------|---------|
| `lib/services/permission_service.dart` | Handles permission logic |
| `lib/services/audio_service.dart` | Uses permission service |
| `lib/widgets/permission_dialog.dart` | Permission UI dialog |
| `lib/voice_capture/cubit/voice_capture_cubit.dart` | State management |

## Need Help?

1. **Check console** for 🎤/✅/❌ logs
2. **Read** `PERMISSION_IMPLEMENTATION_SUMMARY.md`
3. **See detailed docs** in `MICROPHONE_PERMISSION_IMPLEMENTATION.md`

## Success Criteria ✅

- [ ] Permission dialog appears
- [ ] Console shows "✅ Microphone permission granted"
- [ ] Blue button is active
- [ ] Can record voice (press and hold button)
- [ ] Transcription appears while speaking

**That's it! You're ready to go!** 🎉
