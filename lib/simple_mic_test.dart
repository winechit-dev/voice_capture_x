import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ultra-simple microphone test - just request and show result
class SimpleMicTest extends StatefulWidget {
  const SimpleMicTest({super.key});

  @override
  State<SimpleMicTest> createState() => _SimpleMicTestState();
}

class _SimpleMicTestState extends State<SimpleMicTest> {
  String _result = 'Press button to test';
  bool _isRequesting = false;

  Future<void> _testMicrophone() async {
    setState(() {
      _isRequesting = true;
      _result = '⏳ Requesting permission...\nLook for iOS dialog!';
    });

    // ignore: avoid_print
    print('🎤 === STARTING MICROPHONE TEST ===');
    // ignore: avoid_print
    print('🎤 About to call Permission.microphone.request()...');

    try {
      // Direct permission request - nothing fancy
      final status = await Permission.microphone.request();

      // ignore: avoid_print
      print('🎤 Result: $status');

      String message;
      if (status.isGranted) {
        message = '✅ SUCCESS!\n\nMicrophone permission GRANTED!\n\n'
            'Now check:\nSettings → Voice Capture X\n'
            'You should see Microphone listed there.';
        // ignore: avoid_print
        print('✅✅✅ PERMISSION GRANTED! ✅✅✅');
      } else if (status.isDenied) {
        message = '❌ DENIED\n\nYou tapped "Don\'t Allow".\n\n'
            'Try again and tap "Allow" this time.';
        // ignore: avoid_print
        print('❌ Permission denied');
      } else if (status.isPermanentlyDenied) {
        message = '⛔ PERMANENTLY DENIED\n\n'
            'Go to:\nSettings → Voice Capture X\n'
            'Enable Microphone';
        // ignore: avoid_print
        print('⛔ Permission permanently denied');
      } else {
        message = '❓ Unknown result: $status';
        // ignore: avoid_print
        print('❓ Unknown result: $status');
      }

      setState(() {
        _result = message;
        _isRequesting = false;
      });
    } catch (e, stack) {
      // ignore: avoid_print
      print('❌ ERROR: $e');
      // ignore: avoid_print
      print('Stack: $stack');

      setState(() {
        _result = '❌ ERROR:\n\n$e\n\nCheck console for details.';
        _isRequesting = false;
      });
    }

    // ignore: avoid_print
    print('🎤 === TEST COMPLETE ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Mic Test'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.mic,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              const Text(
                'SIMPLE MICROPHONE TEST',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This will request microphone permission '
                'and show you the result.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 48),
              if (_isRequesting)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _testMicrophone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('REQUEST PERMISSION NOW'),
                  ),
                ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              const Card(
                color: Colors.yellow,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '⚠️ IMPORTANT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Watch your screen for the iOS permission dialog!\n\n'
                        'Also check the console/terminal for debug output.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32), // Extra bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
