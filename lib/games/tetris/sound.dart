import 'dart:async';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void StateChangeCallback(AudioPlayerState currentState);

class Sound {
  final String url;
  final bool loop;
  final VoidCallback onComplete;
  final StateChangeCallback onStateChange;

  AudioPlayer _player;
  StreamSubscription<AudioPlayerState> _stateSubscription;

  AudioPlayerState get playerState => _player.state;
  Duration get duration => _player.duration;

  static Future<Sound> playFromAsset(
    String assetDirPath, String fileName, {
      bool loop,
      VoidCallback onComplete,
      StateChangeCallback onStateChange,
    }
  ) async {
    Directory temporaryDir = await pathProvider.getTemporaryDirectory();
    File temporaryFile = File('${temporaryDir.path}/$fileName');
    if (await temporaryFile.exists()) {
      print('file exists, filePath=${temporaryFile.path}');
      Sound sound = Sound(
        url: temporaryFile.path,
        loop: loop,
        onComplete: onComplete,
        onStateChange: onStateChange,
      );
      sound.play();
      return sound;
    }
    final ByteData soundData = await rootBundle.load('$assetDirPath$fileName');
    final bytes = soundData.buffer.asUint8List();
    await temporaryFile.writeAsBytes(bytes, flush: true);
    print('finished loading, filePath=${temporaryFile.path}');
    Sound sound = Sound(
      url: temporaryFile.path,
      loop: loop,
      onComplete: onComplete,
      onStateChange: onStateChange,
    );
    sound.play();
    return sound;
  }

  Sound({
    @required this.url,
    this.loop = false,
    this.onComplete,
    this.onStateChange,
  }) {
    _player = AudioPlayer();
  }
  Future<void> play() async {
    _player?.stop();
    await _player.play(url, isLocal: true);
    _stateSubscription?.cancel();
    _stateSubscription = _player.onPlayerStateChanged.listen((AudioPlayerState currentState) {
      if (onStateChange != null) onStateChange(currentState);
      if (currentState == AudioPlayerState.COMPLETED) {
        if (loop == true) play();
        if (onComplete != null) onComplete();
      }
    });
  }
  Future<void> pause() async {
    await _player.pause();
  }
  Future<void> stop() async {
    await _player.stop();
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }
}