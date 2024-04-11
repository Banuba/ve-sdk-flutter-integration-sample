import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_ve_sdk/audio_browser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(MyApp());
}

/// The entry point for Audio Browser implementation
@pragma('vm:entry-point')
void audioBrowser() => runApp(AudioBrowserWidget());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Banuba Video and Photo Editor SDK Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    this.title = '',
  }) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Set Banuba license token for Video and Photo Editor SDK
  static const String LICENSE_TOKEN = ;

  // For Video Editor
  static const methodInitVideoEditor = 'initVideoEditor';
  static const methodStartVideoEditor = 'startVideoEditor';
  static const methodStartVideoEditorPIP = 'startVideoEditorPIP';
  static const methodStartVideoEditorTrimmer = 'startVideoEditorTrimmer';
  static const methodDemoPlayExportedVideo = 'playExportedVideo';

  static const argExportedVideoFile = 'argExportedVideoFilePath';
  static const argExportedVideoCoverPreviewPath = 'argExportedVideoCoverPreviewPath';

  // For Photo Editor
  static const methodStartPhotoEditor = 'startPhotoEditor';
  static const argExportedPhotoFile = 'argExportedPhotoFilePath';

  static const platformChannel = MethodChannel('banubaSdkChannel');

  String _errorMessage = '';

  Future<void> _startPhotoEditor() async {
    try {
      dynamic result = await platformChannel.invokeMethod(methodStartPhotoEditor, LICENSE_TOKEN);

      debugPrint('Received Photo Editor result');

      // You can pass any values from platform to Flutter as a result.
      if (result is Map) {
        final exportedPhotoFilePath = result[argExportedPhotoFile];
        debugPrint('Exported photo file = $exportedPhotoFilePath');
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _initVideoEditor() async {
    // Create params
    final params = <String, dynamic>{
      'banubaToken': LICENSE_TOKEN,
      'cameraVideoDurations': [30000, 20000, 10000, 5000], // 30, 20, 10, 5 seconds
    };

    // Pass params to platforms
    await platformChannel.invokeMethod(methodInitVideoEditor, params);
  }

  Future<void> _startVideoEditorDefault() async {
    try {
      await _initVideoEditor();

      final result = await platformChannel.invokeMethod(methodStartVideoEditor);

      _handleVideoEditorResult(result);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _startVideoEditorPIP() async {
    try {
      await _initVideoEditor();

      // Use your implementation to provide correct video file path to start Video Editor SDK in PIP mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint('Cannot open video editor with PIP - video was not selected!');
      } else {
        debugPrint('Open video editor in pip with video = ${file.path}');
        final result = await platformChannel.invokeMethod(methodStartVideoEditorPIP, file.path);

        _handleVideoEditorResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _startVideoEditorTrimmer() async {
    try {
      await _initVideoEditor();

      // Use your implementation to provide correct video file path to start Video Editor SDK in Trimmer mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint('Cannot open video editor with Trimmer - video was not selected!');
      } else {
        debugPrint('Open video editor in trimmer with video = ${file.path}');
        final result = await platformChannel.invokeMethod(methodStartVideoEditorTrimmer, file.path);

        _handleVideoEditorResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  // Handle exceptions thrown on Android, iOS platform while starting Video and Photo Editor SDK
  void _handlePlatformException(PlatformException exception) {
    debugPrint("Error: '${exception.message}'.");

    String errorMessage = '';
    switch (exception.code) {
      case 'ERR_SDK_LICENSE_REVOKED':
        errorMessage =
            'The license is revoked or expired. Please contact Banuba https://www.banuba.com/faq/kb-tickets/new';
        break;
      case 'ERR_SDK_NOT_INITIALIZED':
        errorMessage =
            'Banuba Video and Photo Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba';
        break;
      case 'ERR_MISSING_EXPORT_RESULT':
        errorMessage = 'Missing video export result!';
        break;
      case 'ERR_START_PIP_MISSING_VIDEO':
        errorMessage = 'Cannot start video editor in PIP mode: passed video is missing or invalid';
        break;
      case 'ERR_START_TRIMMER_MISSING_VIDEO':
        errorMessage = 'Cannot start video editor in trimmer mode: passed video is missing or invalid';
        break;
      case 'ERR_EXPORT_PLAY_MISSING_VIDEO':
        errorMessage = 'Missing video file to play';
        break;
      default:
        errorMessage = 'unknown error';
    }

    _errorMessage = errorMessage;
    setState(() {});
  }

  void _handleVideoEditorResult(dynamic result) {
    debugPrint('Received Video Editor result');

    // You can use any kind of export result passed from platform.
    // Map is used for this sample to demonstrate playing exported video file.
    if (result is Map) {
      final exportedVideoFilePath = result[argExportedVideoFile];

      debugPrint('Exported video = $exportedVideoFilePath');

      // Use video cover preview to meet your requirements
      final exportedVideoCoverPreviewPath = result[argExportedVideoCoverPreviewPath];

      debugPrint('Exported video preview = $exportedVideoCoverPreviewPath');

      _showConfirmation(context, "Play exported video file?", () {
        platformChannel.invokeMethod(methodDemoPlayExportedVideo, exportedVideoFilePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'The sample demonstrates how to run Banuba Video and Photo Editor SDK with Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Linkify(
                text: _errorMessage,
                onOpen: (link) async {
                  if (await canLaunchUrlString(link.url)) {
                    await launchUrlString(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              disabledColor: Colors.greenAccent,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startPhotoEditor(),
              child: const Text(
                'Open Photo Editor',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorDefault(),
              child: const Text(
                'Open Video Editor - Default',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorPIP(),
              child: const Text(
                'Open Video Editor - PIP',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorTrimmer(),
              child: const Text(
                'Open Video Editor - Trimmer',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(
      BuildContext context, String message, VoidCallback block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.redAccent,
            onPressed: () => {Navigator.pop(context)},
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.greenAccent,
            onPressed: () {
              Navigator.pop(context);
              block.call();
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
