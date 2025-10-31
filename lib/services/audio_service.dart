import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_capture_x/services/permission_service.dart';

/// Service handling audio recording, playback, and transcription
class AudioService {
  AudioService()
      : _recorder = AudioRecorder(),
        _player = AudioPlayer(),
        _speechToText = stt.SpeechToText(),
        _permissionService = PermissionService();

  final AudioRecorder _recorder;
  final AudioPlayer _player;
  final stt.SpeechToText _speechToText;
  final PermissionService _permissionService;

  bool _isInitialized = false;
  String _currentRecordingPath = '';

  /// Stream controller for transcription results
  final _transcriptionController = StreamController<String>.broadcast();

  /// Stream of transcription text as speech is recognized
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  /// Current player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Current player position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get permission service for external use
  PermissionService get permissionService => _permissionService;

  /// Request and check microphone permission
  Future<MicrophonePermissionResult> requestMicrophonePermission() async {
    return await _permissionService.requestMicrophonePermission();
  }

  /// Check if microphone is granted
  Future<bool> checkMicrophonePermission() async {
    return await _permissionService.isMicrophoneGranted();
  }

  /// Initialize speech-to-text with permission handling
  Future<bool> initializeSpeechToText() async {
    if (_isInitialized) {
      // ignore: avoid_print
      print('✅ Speech-to-text already initialized');
      return true;
    }

    try {
      // ignore: avoid_print
      print('🎤 Requesting microphone permission...');

      // Request microphone permission
      final permissionResult = await requestMicrophonePermission();

      if (!permissionResult.isGranted) {
        // ignore: avoid_print
        print('❌ ${permissionResult.message}');
        return false;
      }

      // ignore: avoid_print
      print('✅ Microphone permission granted');

      // Initialize speech-to-text (handles speech recognition permission internally)
      // ignore: avoid_print
      print('🔊 Initializing speech-to-text...');

      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          // ignore: avoid_print
          print('❌ Speech-to-text error: $error');
          _transcriptionController.addError(error);
        },
        onStatus: (status) {
          // ignore: avoid_print
          print('🔊 Speech-to-text status: $status');
        },
      );

      if (_isInitialized) {
        // ignore: avoid_print
        print('✅ Speech-to-text initialized successfully');
      } else {
        // ignore: avoid_print
        print('⚠️ Speech-to-text initialization failed (but mic is granted)');
      }

      return _isInitialized;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Exception during initialization: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<String?> startRecording() async {
    try {
      if (!await checkMicrophonePermission()) {
        throw Exception('Microphone permission not granted');
      }

      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

      // Check if recorder supports the format
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath,
        );

        // Start speech-to-text listening
        if (_isInitialized && !_speechToText.isListening) {
          await _speechToText.listen(
            onResult: (result) {
              _transcriptionController.add(result.recognizedWords);
            },
            listenMode: stt.ListenMode.confirmation,
          );
        }

        return _currentRecordingPath;
      }
      return null;
    } catch (e) {
      _transcriptionController.addError(e);
      return null;
    }
  }

  /// Stop recording and return the file path and final transcription
  Future<({String? filePath, String transcription})> stopRecording() async {
    try {
      final path = await _recorder.stop();

      // Stop speech-to-text
      String transcription = '';
      if (_speechToText.isListening) {
        await _speechToText.stop();
        transcription = _speechToText.lastRecognizedWords;
      }

      return (filePath: path, transcription: transcription);
    } catch (e) {
      _transcriptionController.addError(e);
      return (filePath: null, transcription: '');
    }
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return _recorder.isRecording();
  }

  /// Play an audio file
  Future<void> playAudio(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    await _player.play();
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Get the duration of the currently loaded audio
  Duration? get duration => _player.duration;

  /// Delete a recording file
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    return await _permissionService.openAppSettings();
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
    await _transcriptionController.close();
  }
}
