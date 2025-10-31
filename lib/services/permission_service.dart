import 'package:permission_handler/permission_handler.dart';

/// Service for handling app permissions
class PermissionService {
  /// Check if microphone permission is granted
  Future<bool> isMicrophoneGranted() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Check if microphone permission is permanently denied
  Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  /// Request microphone permission
  Future<PermissionStatus> requestMicrophone() async {
    return Permission.microphone.request();
  }

  /// Request microphone permission with detailed result
  Future<MicrophonePermissionResult> requestMicrophonePermission() async {
    // Check current status first
    final currentStatus = await Permission.microphone.status;

    // If already granted, return immediately
    if (currentStatus.isGranted) {
      return const MicrophonePermissionResult(
        isGranted: true,
        status: MicrophonePermissionStatus.granted,
        message: 'Microphone permission already granted',
      );
    }

    // If permanently denied, user must go to settings
    if (currentStatus.isPermanentlyDenied) {
      return const MicrophonePermissionResult(
        isGranted: false,
        status: MicrophonePermissionStatus.permanentlyDenied,
        message: 'Microphone permission permanently denied. '
            'Please enable it in Settings.',
      );
    }

    // Request permission
    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return const MicrophonePermissionResult(
        isGranted: true,
        status: MicrophonePermissionStatus.granted,
        message: 'Microphone permission granted',
      );
    } else if (result.isDenied) {
      return const MicrophonePermissionResult(
        isGranted: false,
        status: MicrophonePermissionStatus.denied,
        message: 'Microphone permission denied. Tap to try again.',
      );
    } else if (result.isPermanentlyDenied) {
      return const MicrophonePermissionResult(
        isGranted: false,
        status: MicrophonePermissionStatus.permanentlyDenied,
        message: 'Microphone permission permanently denied.'
            ' Please enable it in Settings.',
      );
    } else if (result.isRestricted) {
      return const MicrophonePermissionResult(
        isGranted: false,
        status: MicrophonePermissionStatus.restricted,
        message: 'Microphone access is restricted on this device.',
      );
    } else {
      return const MicrophonePermissionResult(
        isGranted: false,
        status: MicrophonePermissionStatus.denied,
        message: 'Unable to access microphone.',
      );
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return openAppSettings();
  }

  /// Check if speech recognition is available (iOS)
  Future<bool> isSpeechRecognitionAvailable() async {
    try {
      final status = await Permission.speech.status;
      return !status.isPermanentlyDenied;
    } catch (e) {
      // Speech permission might not be available on all platforms
      return true; // Assume available
    }
  }

  /// Request speech recognition permission (iOS)
  Future<bool> requestSpeechRecognition() async {
    try {
      final status = await Permission.speech.request();
      return status.isGranted;
    } catch (e) {
      // Speech permission might not be available on all platforms
      return true; // Assume granted on platforms that don't need it
    }
  }
}

/// Result of microphone permission request
class MicrophonePermissionResult {
  const MicrophonePermissionResult({
    required this.isGranted,
    required this.status,
    required this.message,
  });

  final bool isGranted;
  final MicrophonePermissionStatus status;
  final String message;

  bool get shouldShowSettings =>
      status == MicrophonePermissionStatus.permanentlyDenied;

  bool get canRetry => status == MicrophonePermissionStatus.denied;
}

/// Status of microphone permission
enum MicrophonePermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}
