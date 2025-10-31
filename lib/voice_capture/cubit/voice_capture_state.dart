import 'package:equatable/equatable.dart';
import 'package:voice_capture_x/models/voice_recording.dart';

/// Status of the voice capture feature
enum VoiceCaptureStatus {
  /// Initial state, ready to record
  idle,

  /// Currently recording audio
  recording,

  /// Processing the recording (transcribing, saving)
  processing,

  /// Playing back a recording
  playing,

  /// Error state
  error,
}

/// State for voice capture feature
class VoiceCaptureState extends Equatable {
  const VoiceCaptureState({
    this.status = VoiceCaptureStatus.idle,
    this.recordings = const [],
    this.currentTranscription = '',
    this.currentPlayingId,
    this.playbackPosition = Duration.zero,
    this.errorMessage,
    this.isInitialized = false,
  });

  /// Current status of the voice capture
  final VoiceCaptureStatus status;

  /// List of all recordings
  final List<VoiceRecording> recordings;

  /// Current live transcription text
  final String currentTranscription;

  /// ID of the recording currently being played
  final String? currentPlayingId;

  /// Current playback position
  final Duration playbackPosition;

  /// Error message if status is error
  final String? errorMessage;

  /// Whether speech-to-text is initialized
  final bool isInitialized;

  /// Copy with method for immutability
  VoiceCaptureState copyWith({
    VoiceCaptureStatus? status,
    List<VoiceRecording>? recordings,
    String? currentTranscription,
    String? currentPlayingId,
    Duration? playbackPosition,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return VoiceCaptureState(
      status: status ?? this.status,
      recordings: recordings ?? this.recordings,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      currentPlayingId: currentPlayingId ?? this.currentPlayingId,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Clear current playing ID
  VoiceCaptureState clearPlayingId() {
    return VoiceCaptureState(
      status: status,
      recordings: recordings,
      currentTranscription: currentTranscription,
      playbackPosition: playbackPosition,
      errorMessage: errorMessage,
      isInitialized: isInitialized,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recordings,
        currentTranscription,
        currentPlayingId,
        playbackPosition,
        errorMessage,
        isInitialized,
      ];
}
