import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

final audioRecorderProvider =
    StateNotifierProvider<AudioRecorderNotifier, AudioRecorderState>((ref) {
  return AudioRecorderNotifier();
});

class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  AudioRecorderNotifier() : super(AudioRecorderState());

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'recordings',
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');

      await Directory(
        p.dirname(path),
      ).create(
        recursive: true,
      );

      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );
      state = state.copyWith(
        isRecording: true,
        audioFilePath: path,
      );
    }
  }

  Future<void> stopRecording() async {
    final path = await _audioRecorder.stop();
    state = state.copyWith(
      isRecording: false,
      audioFilePath: path,
    );
  }

  Future<void> playRecording() async {
    if (state.audioFilePath != null) {
      state = state.copyWith(isPlaying: true);
      await _audioPlayer.setFilePath(state.audioFilePath!);
      await _audioPlayer.play();
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
    state = state.copyWith(isPlaying: false);
  }

  String? getAudioFilePath() {
    return state.audioFilePath;
  }
}

class AudioRecorderState {
  final bool isRecording;
  final bool isPlaying;
  final String? audioFilePath;

  AudioRecorderState({
    this.isRecording = false,
    this.isPlaying = false,
    this.audioFilePath,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    bool? isPlaying,
    String? audioFilePath,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      audioFilePath: audioFilePath ?? this.audioFilePath,
    );
  }
}
