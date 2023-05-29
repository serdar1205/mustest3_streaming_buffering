import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  static const url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

  late AudioPlayer _audioPlayer;

  PageManager() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(url);

    /// button state
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      }else if(processingState != ProcessingState.completed){
        buttonNotifier.value = ButtonState.playing;
      }
      else {
        ///completed
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    /// progress bar

    /// 1 thumb position

    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;

      progressNotifier.value = ProgressBarState(
          current: position,
          buffered: oldState.buffered,
          total: oldState.total);
    });

    /// 2 Listening to the buffered position stream
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
          current: oldState.current,
          buffered: bufferedPosition,
          total: oldState.total);
    });

    /// 3 Listening to the duration stream
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  final Duration current;
  final Duration buffered;
  final Duration total;

  ProgressBarState(
      {required this.current, required this.buffered, required this.total});
}

enum ButtonState { paused, playing, loading }
