import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voice_capture_x/l10n/l10n.dart';
import 'package:voice_capture_x/models/voice_recording.dart';
import 'package:voice_capture_x/services/audio_service.dart';
import 'package:voice_capture_x/voice_capture/cubit/voice_capture_cubit.dart';
import 'package:voice_capture_x/voice_capture/cubit/voice_capture_state.dart';

/// Voice Capture page with push-to-talk functionality
class VoiceCapturePage extends StatelessWidget {
  const VoiceCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VoiceCaptureCubit(
        audioService: AudioService(),
      ),
      child: const VoiceCaptureView(),
    );
  }
}

/// Main view for voice capture
class VoiceCaptureView extends StatelessWidget {
  const VoiceCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voiceCaptureTitle),
        centerTitle: true,
      ),
      body: BlocConsumer<VoiceCaptureCubit, VoiceCaptureState>(
        listener: (context, state) {
          if (state.status == VoiceCaptureStatus.error) {
            final isPermissionError =
                state.errorMessage?.contains('permission') ?? false;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.errorOccurred),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: isPermissionError ? 'Retry' : l10n.dismiss,
                  textColor: Colors.white,
                  onPressed: () {
                    if (isPermissionError) {
                      context.read<VoiceCaptureCubit>().retryInitialization();
                    } else {
                      context.read<VoiceCaptureCubit>().clearError();
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Recording status and transcription area
              _RecordingStatusSection(state: state),

              // Push-to-talk button
              const SizedBox(height: 32),
              _PushToTalkButton(
                status: state.status,
                isInitialized: state.isInitialized,
              ),

              // Recordings list
              const SizedBox(height: 32),
              Expanded(
                child: _RecordingsList(recordings: state.recordings),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Recording status and live transcription display
class _RecordingStatusSection extends StatelessWidget {
  const _RecordingStatusSection({required this.state});

  final VoiceCaptureState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    String statusText;
    Color statusColor;

    switch (state.status) {
      case VoiceCaptureStatus.recording:
        statusText = l10n.statusRecording;
        statusColor = Colors.red;
      case VoiceCaptureStatus.processing:
        statusText = l10n.statusProcessing;
        statusColor = Colors.orange;
      case VoiceCaptureStatus.playing:
        statusText = l10n.statusPlaying;
        statusColor = Colors.blue;
      default:
        statusText = l10n.statusReady;
        statusColor = Colors.green;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: statusColor, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.status == VoiceCaptureStatus.recording)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                statusText,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (state.currentTranscription.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                state.currentTranscription,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Push-to-talk button
class _PushToTalkButton extends StatelessWidget {
  const _PushToTalkButton({
    required this.status,
    required this.isInitialized,
  });

  final VoiceCaptureStatus status;
  final bool isInitialized;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRecording = status == VoiceCaptureStatus.recording;
    final isDisabled = !isInitialized ||
        status == VoiceCaptureStatus.processing ||
        status == VoiceCaptureStatus.playing ||
        status == VoiceCaptureStatus.error;

    return GestureDetector(
      onTap: (isDisabled && !isInitialized)
          ? () => context.read<VoiceCaptureCubit>().retryInitialization()
          : null,
      onTapDown: isDisabled
          ? null
          : (_) => context.read<VoiceCaptureCubit>().startRecording(),
      onTapUp: isDisabled
          ? null
          : (_) => context.read<VoiceCaptureCubit>().stopRecording(),
      onTapCancel: isDisabled
          ? null
          : () => context.read<VoiceCaptureCubit>().stopRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 200 : 160,
        height: isRecording ? 200 : 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? Colors.grey
              : (isRecording ? Colors.red : Colors.blue),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? Colors.red : Colors.blue)
                  .withValues(alpha: 0.5),
              blurRadius: isRecording ? 30.0 : 15.0,
              spreadRadius: isRecording ? 10.0 : 5.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDisabled
                    ? Icons.mic_off
                    : (isRecording ? Icons.stop : Icons.mic),
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  isDisabled && !isInitialized
                      ? 'Grant Permissions'
                      : (isRecording ? l10n.release : l10n.holdToTalk),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of recorded audio files
class _RecordingsList extends StatelessWidget {
  const _RecordingsList({required this.recordings});

  final List<VoiceRecording> recordings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (recordings.isEmpty) {
      return Center(
        child: Text(
          l10n.noRecordings,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final recording = recordings[index];
        return _RecordingTile(recording: recording);
      },
    );
  }
}

/// Individual recording tile
class _RecordingTile extends StatelessWidget {
  const _RecordingTile({required this.recording});

  final VoiceRecording recording;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return BlocBuilder<VoiceCaptureCubit, VoiceCaptureState>(
      builder: (context, state) {
        final isPlaying = state.currentPlayingId == recording.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor:
                  isPlaying ? Colors.blue : theme.colorScheme.primary,
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            title: Text(
              dateFormat.format(recording.timestamp),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${l10n.duration}: ${_formatDuration(recording.duration)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (recording.transcription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    recording.transcription,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<VoiceCaptureCubit>().deleteRecording(recording.id);
              },
            ),
            onTap: () {
              if (isPlaying) {
                context.read<VoiceCaptureCubit>().stopPlayback();
              } else {
                context.read<VoiceCaptureCubit>().playRecording(recording.id);
              }
            },
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
