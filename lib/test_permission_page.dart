import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple test page to diagnose microphone permission issues
class TestPermissionPage extends StatefulWidget {
  const TestPermissionPage({super.key});

  @override
  State<TestPermissionPage> createState() => _TestPermissionPageState();
}

class _TestPermissionPageState extends State<TestPermissionPage> {
  String _status = 'Not checked';
  String _log = '';

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
    // ignore: avoid_print
    print(message);
  }

  Future<void> _checkPermission() async {
    _addLog('📋 Checking microphone permission status...');

    try {
      final status = await Permission.microphone.status;
      _addLog('Current status: $status');

      setState(() {
        if (status.isGranted) {
          _status = '✅ GRANTED';
          _addLog('✅ Microphone permission is GRANTED');
        } else if (status.isDenied) {
          _status = '❌ DENIED';
          _addLog('❌ Microphone permission is DENIED');
        } else if (status.isPermanentlyDenied) {
          _status = '⛔ PERMANENTLY DENIED';
          _addLog('⛔ Microphone permission is PERMANENTLY DENIED');
        } else if (status.isRestricted) {
          _status = '🚫 RESTRICTED';
          _addLog('🚫 Microphone permission is RESTRICTED');
        } else if (status.isLimited) {
          _status = '⚠️ LIMITED';
          _addLog('⚠️ Microphone permission is LIMITED');
        } else {
          _status = '❓ UNKNOWN';
          _addLog('❓ Unknown status: $status');
        }
      });
    } catch (e) {
      _addLog('❌ ERROR checking permission: $e');
      setState(() {
        _status = 'ERROR';
      });
    }
  }

  Future<void> _requestPermission() async {
    _addLog('\n🎤 REQUESTING microphone permission...');

    try {
      final result = await Permission.microphone.request();
      _addLog('Request result: $result');

      setState(() {
        if (result.isGranted) {
          _status = '✅ GRANTED';
          _addLog('✅✅✅ SUCCESS! Permission GRANTED! ✅✅✅');
        } else if (result.isDenied) {
          _status = '❌ DENIED';
          _addLog('❌ Permission DENIED by user');
        } else if (result.isPermanentlyDenied) {
          _status = '⛔ PERMANENTLY DENIED';
          _addLog('⛔ Permission PERMANENTLY DENIED - go to Settings');
        } else {
          _status = '❓ $result';
          _addLog('❓ Unexpected result: $result');
        }
      });

      // Check again after request
      _addLog('\n🔄 Checking status after request...');
      await _checkPermission();
    } catch (e) {
      _addLog('❌ ERROR requesting permission: $e');
      _addLog('Exception type: ${e.runtimeType}');
      setState(() {
        _status = 'ERROR: $e';
      });
    }
  }

  Future<void> _openSettings() async {
    _addLog('\n📱 Opening app settings...');
    try {
      final opened = await openAppSettings();
      _addLog(opened ? '✅ Settings opened' : '❌ Failed to open settings');
    } catch (e) {
      _addLog('❌ ERROR opening settings: $e');
    }
  }

  void _clearLog() {
    setState(() {
      _log = '';
      _status = 'Not checked';
    });
  }

  @override
  void initState() {
    super.initState();
    // Check permission immediately on load
    Future.delayed(Duration.zero, _checkPermission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Test'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  const Text(
                    'Microphone Permission Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _checkPermission,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Check Permission Status'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _requestPermission,
                      icon: const Icon(Icons.mic),
                      label: const Text('REQUEST PERMISSION'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearLog,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Log'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Log Display
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Debug Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _log.isEmpty ? 'No logs yet...' : _log,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
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
