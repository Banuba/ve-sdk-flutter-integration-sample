import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:flutter_ve_sdk/file_provider.dart';

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
  static const platform = MethodChannel('audioBrowserChannel');

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
                onPressed: () {
                  _useLocalAudio();
                },
                child: const Text(
                  'Use local audio',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              MaterialButton(
                color: Colors.yellow,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  _stopUsingCurrentTrack();
                },
                child: const Text(
                  'Stop using track',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              MaterialButton(
                color: Colors.grey,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  _close();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _useLocalAudio() async {
    try {
      // Banuba VE is not responsible for downloading music track. You should use local URI to music file here
      final trackUrl = await FilePlugin().createAssetFileUri("assets/audio/", "sample_audio.mp3");
      final args = {
        "url": trackUrl.toString(),
        "id": 111,
        "title": "My favorite song",
      };
      final result = await platform.invokeMethod(
        'trackSelected',
        jsonEncode(args),
      );
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }

  Future<void> _stopUsingCurrentTrack() async {
    try {
      final args = {
        "id": 111,
      };
      final result = await platform.invokeMethod(
        'stopUsingTrack',
        jsonEncode(args),
      );
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }

  Future<void> _close() async {
    try {
      final result = await platform.invokeMethod('close');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }
}
