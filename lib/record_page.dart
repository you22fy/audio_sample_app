import 'package:audio_recorder_app/m4a_to_base64.dart';
import 'package:audio_recorder_app/record_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordPage extends HookConsumerWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioRecorderProvider);
    final notifier = ref.watch(audioRecorderProvider.notifier);

    final base64Audio = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('録音アプリ'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (state.isRecording) {
                    notifier.stopRecording();
                  } else {
                    notifier.startRecording();
                  }
                },
                child: Text(
                  state.isRecording ? '停止' : '開始',
                ),
              ),
              const SizedBox(height: 20),
              if (state.isRecording)
                const Text(
                  '録音中',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              if (state.audioFilePath != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (state.isPlaying) {
                      notifier.stopPlaying();
                    } else {
                      notifier.playRecording();
                    }
                  },
                  child: Text(
                    state.isPlaying ? '再生停止' : '再生',
                  ),
                ),
              ],
              if (state.isPlaying)
                const Text(
                  '再生中',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  final audioFilePath = notifier.getAudioFilePath();
                  if (audioFilePath != null) {
                    final base64String =
                        await convertM4aToBase64(audioFilePath);
                    base64Audio.value = base64String;
                  }
                },
                child: const Text('base64'),
              ),
              if (base64Audio.value != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Base64: ${base64Audio.value}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
