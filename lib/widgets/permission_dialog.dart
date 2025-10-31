import 'package:flutter/material.dart';
import 'package:voice_capture_x/services/permission_service.dart';

/// Dialog to request microphone permission
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({
    required this.result,
    super.key,
  });

  final MicrophonePermissionResult result;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.mic_off,
        size: 64,
        color: Theme.of(context).colorScheme.error,
      ),
      title: const Text('Microphone Access Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (result.shouldShowSettings)
            const Text(
              'Go to Settings → Voice Capture X → Enable Microphone',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (result.shouldShowSettings)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow Access'),
          ),
      ],
    );
  }

  /// Show permission dialog
  static Future<bool?> show(
    BuildContext context,
    MicrophonePermissionResult result,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(result: result),
    );
  }
}

/// Permission request overlay widget
class PermissionRequestOverlay extends StatelessWidget {
  const PermissionRequestOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mic,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Microphone Permission',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This app needs access to your microphone to record voice '
                  'messages.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                const Text(
                  'Waiting for permission...',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
