import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class AudioPreview extends StatefulWidget {
  final String audio;

  const AudioPreview({
    super.key,
    required this.audio,
  });

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await player.setUrl(widget.audio);
      await player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 32,
              ),
            ),
          )
        ],
      ),
    );
  }
}
