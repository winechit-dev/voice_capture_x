import 'package:equatable/equatable.dart';

/// Model representing a voice recording with its metadata
class VoiceRecording extends Equatable {
  const VoiceRecording({
    required this.id,
    required this.filePath,
    required this.timestamp,
    this.duration = Duration.zero,
    this.transcription = '',
  });

  /// Unique identifier for the recording
  final String id;

  /// File path where the audio is stored
  final String filePath;

  /// When the recording was created
  final DateTime timestamp;

  /// Duration of the recording
  final Duration duration;

  /// Transcribed text from speech-to-text
  final String transcription;

  /// Copy with method for immutability
  VoiceRecording copyWith({
    String? id,
    String? filePath,
    DateTime? timestamp,
    Duration? duration,
    String? transcription,
  }) {
    return VoiceRecording(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      transcription: transcription ?? this.transcription,
    );
  }

  @override
  List<Object?> get props => [id, filePath, timestamp, duration, transcription];
}
