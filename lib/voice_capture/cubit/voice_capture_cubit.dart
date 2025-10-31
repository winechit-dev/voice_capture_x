import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_capture_x/models/voice_recording.dart';
import 'package:voice_capture_x/services/audio_service.dart';
import 'package:voice_capture_x/services/permission_service.dart';
import 'package:voice_capture_x/voice_capture/cubit/voice_capture_state.dart';

/// Cubit managing voice capture functionality
class VoiceCaptureCubit extends Cubit<VoiceCaptureState> {
  VoiceCaptureCubit({
    required AudioService audioService,
  })  : _audioService = audioService,
        super(const VoiceCaptureState()) {
    _init();
  }

  final AudioService _audioService;
  final _uuid = const Uuid();
  StreamSubscription<String>? _transcriptionSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  DateTime? _recordingStartTime;
  MicrophonePermissionResult? _lastPermissionResult;

  /// Initialize the service
  Future<void> _init() async {
    try {
      // ignore: avoid_print
      print('🎬 Initializing Voice Capture...');

      final initialized = await _audioService.initializeSpeechToText();

      if (!initialized) {
        // Check microphone permission status
        final hasMicPermission =
            await _audioService.checkMicrophonePermission();

        if (!hasMicPermission) {
          // Store the last permission request result
          _lastPermissionResult =
              await _audioService.requestMicrophonePermission();

          // ignore: avoid_print
          print('❌ Initialization failed: ${_lastPermissionResult?.message}');

          emit(
            state.copyWith(
              status: VoiceCaptureStatus.error,
              errorMessage: _lastPermissionResult?.message ??
                  'Microphone permission denied.',
              isInitialized: false,
            ),
          );
        } else {
          // Microphone is granted but speech-to-text failed
          // Allow recording without transcription
          // ignore: avoid_print
          print(
            '⚠️ Speech-to-text unavailable, but recording will work',
          );

          emit(
            state.copyWith(
              status: VoiceCaptureStatus.idle,
              isInitialized: true,
              errorMessage: 'Speech recognition unavailable. '
                  'Recording works but without transcription.',
            ),
          );

          // Clear the warning after 5 seconds
          // Automatically clear the speech recognition warning after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            final error = state.errorMessage;
            final hasSpeechError =
                error != null && error.contains('Speech recognition');

            if (!isClosed && hasSpeechError) {
              emit(state.copyWith());
            }
          });
        }
        return;
      }

      // ignore: avoid_print
      print('✅ Voice Capture initialized successfully');

      emit(state.copyWith(isInitialized: initialized));

      // Listen to transcription updates
      _transcriptionSubscription = _audioService.transcriptionStream.listen(
        (transcription) {
          if (state.status == VoiceCaptureStatus.recording) {
            emit(state.copyWith(currentTranscription: transcription));
          }
        },
        onError: (Object error) {
          emit(
            state.copyWith(
              status: VoiceCaptureStatus.error,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Failed to initialize: $e',
        ),
      );
    }
  }

  /// Start recording (push-to-talk pressed)
  Future<void> startRecording() async {
    if (state.status == VoiceCaptureStatus.recording) return;

    try {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.recording,
          currentTranscription: '',
        ),
      );

      _recordingStartTime = DateTime.now();
      final path = await _audioService.startRecording();

      if (path == null) {
        emit(
          state.copyWith(
            status: VoiceCaptureStatus.error,
            errorMessage: 'Failed to start recording',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Error starting recording: $e',
        ),
      );
    }
  }

  /// Stop recording (push-to-talk released)
  Future<void> stopRecording() async {
    if (state.status != VoiceCaptureStatus.recording) return;

    try {
      emit(state.copyWith(status: VoiceCaptureStatus.processing));

      final result = await _audioService.stopRecording();
      final endTime = DateTime.now();

      if (result.filePath != null && _recordingStartTime != null) {
        final duration = endTime.difference(_recordingStartTime!);

        final recording = VoiceRecording(
          id: _uuid.v4(),
          filePath: result.filePath!,
          timestamp: _recordingStartTime!,
          duration: duration,
          transcription: result.transcription,
        );

        final updatedRecordings = [recording, ...state.recordings];

        emit(
          state.copyWith(
            status: VoiceCaptureStatus.idle,
            recordings: updatedRecordings,
            currentTranscription: '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: VoiceCaptureStatus.error,
            errorMessage: 'Failed to save recording',
          ),
        );
      }

      _recordingStartTime = null;
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Error stopping recording: $e',
        ),
      );
    }
  }

  /// Play a recording
  Future<void> playRecording(String recordingId) async {
    try {
      final recording = state.recordings.firstWhere(
        (r) => r.id == recordingId,
      );

      // Stop current playback if any
      if (state.status == VoiceCaptureStatus.playing) {
        await _audioService.stopPlayback();
        await _positionSubscription?.cancel();
      }

      emit(
        state.copyWith(
          status: VoiceCaptureStatus.playing,
          currentPlayingId: recordingId,
          playbackPosition: Duration.zero,
        ),
      );

      await _audioService.playAudio(recording.filePath);

      // Listen to playback position
      _positionSubscription = _audioService.positionStream.listen(
        (position) {
          emit(state.copyWith(playbackPosition: position));
        },
      );

      // Listen to player state to detect when playback completes
      _audioService.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _positionSubscription?.cancel();
          emit(
            state.clearPlayingId().copyWith(
                  status: VoiceCaptureStatus.idle,
                  playbackPosition: Duration.zero,
                ),
          );
        }
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Error playing recording: $e',
        ),
      );
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    try {
      await _audioService.stopPlayback();
      await _positionSubscription?.cancel();

      emit(
        state.clearPlayingId().copyWith(
              status: VoiceCaptureStatus.idle,
              playbackPosition: Duration.zero,
            ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Error stopping playback: $e',
        ),
      );
    }
  }

  /// Delete a recording
  Future<void> deleteRecording(String recordingId) async {
    try {
      final recording = state.recordings.firstWhere(
        (r) => r.id == recordingId,
      );

      // Stop playback if this recording is playing
      if (state.currentPlayingId == recordingId) {
        await stopPlayback();
      }

      await _audioService.deleteRecording(recording.filePath);

      final updatedRecordings =
          state.recordings.where((r) => r.id != recordingId).toList();

      emit(state.copyWith(recordings: updatedRecordings));
    } catch (e) {
      emit(
        state.copyWith(
          status: VoiceCaptureStatus.error,
          errorMessage: 'Error deleting recording: $e',
        ),
      );
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.copyWith(status: VoiceCaptureStatus.idle));
  }

  /// Retry initialization (for permission requests)
  Future<void> retryInitialization() async {
    emit(state.copyWith(status: VoiceCaptureStatus.idle));
    await _init();
  }

  /// Get last permission result
  MicrophonePermissionResult? get lastPermissionResult => _lastPermissionResult;

  /// Open app settings for permissions
  Future<void> openSettings() async {
    final opened = await _audioService.openAppSettings();
    if (opened) {
      // ignore: avoid_print
      print('📱 Opening app settings...');
    }
  }

  @override
  Future<void> close() {
    _transcriptionSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioService.dispose();
    return super.close();
  }
}
