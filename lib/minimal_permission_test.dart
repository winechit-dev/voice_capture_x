import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Absolute minimal test - just request microphone permission
class MinimalPermissionTest extends StatefulWidget {
  const MinimalPermissionTest({super.key});

  @override
  State<MinimalPermissionTest> createState() => _MinimalPermissionTestState();
}

class _MinimalPermissionTestState extends State<MinimalPermissionTest> {
  String _log = '📋 Ready to test\n\n';
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
    // ignore: avoid_print
    print(message);
  }

  Future<void> _testPermission() async {
    setState(() {
      _isTesting = true;
      _log = '';
    });

    _addLog('🎬 Starting permission test...');
    _addLog('');

    try {
      // Step 1: Check Info.plist
      _addLog('✓ Info.plist should contain NSMicrophoneUsageDescription');
      _addLog('');

      // Step 2: Check current status
      _addLog('📋 Checking current permission status...');
      final currentStatus = await Permission.microphone.status;
      _addLog('Current status: $currentStatus');
      _addLog('');

      // Step 3: Request permission
      _addLog('🎤 REQUESTING MICROPHONE PERMISSION...');
      _addLog('⚠️ WATCH YOUR SCREEN FOR iOS DIALOG!');
      _addLog('');

      // This is the actual permission request
      final result = await Permission.microphone.request();

      _addLog('📥 Permission request returned');
      _addLog('Result: $result');
      _addLog('');

      // Step 4: Interpret result
      if (result.isGranted) {
        _addLog('✅✅✅ SUCCESS! ✅✅✅');
        _addLog('');
        _addLog('Microphone permission is GRANTED!');
        _addLog('');
        _addLog('NOW CHECK:');
        _addLog('Settings → Voice Capture X');
        _addLog('You should see "Microphone" listed!');
      } else if (result.isDenied) {
        _addLog('❌ DENIED');
        _addLog('');
        _addLog('You tapped "Don\'t Allow"');
        _addLog('');
        _addLog('TO FIX:');
        _addLog('1. Tap the button again');
        _addLog('2. This time tap "Allow"');
      } else if (result.isPermanentlyDenied) {
        _addLog('⛔ PERMANENTLY DENIED');
        _addLog('');
        _addLog('Permission was denied multiple times');
        _addLog('');
        _addLog('TO FIX:');
        _addLog('1. Go to Settings → Voice Capture X');
        _addLog('2. Enable Microphone toggle');
        _addLog('3. Come back and test again');
      } else if (result.isRestricted) {
        _addLog('🚫 RESTRICTED');
        _addLog('');
        _addLog('Device has restrictions');
        _addLog('Check Screen Time / Parental Controls');
      } else {
        _addLog('❓ UNKNOWN STATUS');
        _addLog('Status: $result');
      }

      _addLog('');
      _addLog('🏁 Test complete');
    } catch (e, stackTrace) {
      _addLog('');
      _addLog('❌❌❌ ERROR ❌❌❌');
      _addLog('');
      _addLog('Error: $e');
      _addLog('');
      _addLog('Stack trace:');
      _addLog(stackTrace.toString());
      _addLog('');
      _addLog('This might mean:');
      _addLog('1. Info.plist is missing NSMicrophoneUsageDescription');
      _addLog('2. Permission handler not properly installed');
      _addLog('3. iOS version too old (need 10.0+)');
    }

    setState(() {
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Permission Test'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions
            Container(
              width: double.infinity,
              color: Colors.purple.shade50,
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, size: 40, color: Colors.purple),
                  SizedBox(height: 8),
                  Text(
                    'This is the simplest possible test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap button below → Watch for iOS dialog',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Test Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: _isTesting
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Watch for permission dialog...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _testPermission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic, size: 32),
                            SizedBox(height: 4),
                            Text('TEST PERMISSION'),
                          ],
                        ),
                      ),
              ),
            ),

            // Log Output
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'DEBUG LOG:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _log,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
