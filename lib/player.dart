import 'package:flutter/material.dart';
import 'page_manager.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final PageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Spacer(),
            ValueListenableBuilder<ProgressBarState>(
                valueListenable: _pageManager.progressNotifier,
                builder: (_, value, child) {
                  return ProgressBar(
                      progress: value.current,
                      buffered: value.buffered,
                      total: value.total);
                }),
            ValueListenableBuilder<ButtonState>(
                valueListenable: _pageManager.buttonNotifier,
                builder: (_, value, child) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 32.0,
                        height: 32.0,
                        child: const CircularProgressIndicator(),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: _pageManager.play,
                      );
                    case ButtonState.playing:
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                        onPressed: _pageManager.pause,
                      );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
