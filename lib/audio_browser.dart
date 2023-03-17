import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ve_sdk/file_plugin.dart';
import 'package:uuid/uuid.dart';

class AudioBrowserWidget extends StatefulWidget {
  AudioBrowserWidget({
    Key? key,
    this.title = 'Audio Browser',
  }) : super(key: key);
  final String title;

  @override
  _AudioBrowserState createState() => _AudioBrowserState();
}

class _AudioBrowserState extends State<AudioBrowserWidget> {
  static const _channelName = 'audioBrowserChannel';
  static const _methodApplyAudioTrack = 'applyAudioTrack';
  static const _methodDiscardAudioTrack = 'discardAudioTrack';
  static const _methodClose = 'close';

  static const _sampleAudioTrack = "sample_audio.mp3";

  static const _methodChannel = MethodChannel(_channelName);

  @override
  Widget build(BuildContext context) {
    return new MediaQuery(
      data: new MediaQueryData.fromWindow(ui.window),
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.blueAccent,
                minWidth: 240,
                onPressed: () {
                  _applyLocalAudio();
                },
                child: const Text(
                  'Apply audio track',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.redAccent,
                minWidth: 240,
                onPressed: () {
                  _discardLocalAudio();
                },
                child: const Text(
                  'Discard audio track',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              MaterialButton(
                color: Colors.grey,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.grey,
                minWidth: 240,
                onPressed: () {
                  _close();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Applies provided audio track in Video Editor SDK
  /// Banuba Video Editor SDK is not responsible for downloading or managing remote audio files.
  /// The SDK can only apply audio file stored on the device.
  /// This sample demonstrates how locally stored audio file can be applied in Video Editor SDK
  Future<void> _applyLocalAudio() async {
    debugPrint('Apply audio track');
    try {
      final audioTrackUri =
          await FilePlugin().createAssetFileUri("assets/audio/", _sampleAudioTrack);

      final dynamic result;
      final args = {
        "url": audioTrackUri.toString(),
        "id": Uuid().v1(),
        "artist": "The best artist",
        "title": "My favorite song",
      };

      result = await _methodChannel.invokeMethod(_methodApplyAudioTrack, jsonEncode(args));

      debugPrint('Apply audio track result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error while applying audio track: '${e.message}'.");
    }
  }

  /// Discards last used audio track in Video Editor SDK
  /// Use this method if you need to reset audio track.
  /// The user decides to discard or change previous audio track on your custom audio browser screen.
  Future<void> _discardLocalAudio() async {
    debugPrint('Discard audio track');
    try {
      final result = await _methodChannel.invokeMethod(_methodDiscardAudioTrack);
      debugPrint('Discard audio track result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error while discarding audio track: '${e.message}'.");
    }
  }

  /// Closes custom audio browser. In this case previous audio track will be used
  Future<void> _close() async {
    debugPrint('Close custom audio browser');

    try {
      final result = await _methodChannel.invokeMethod(_methodClose);
      debugPrint('Close result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error while closing: '${e.message}'.");
    }
  }
}
