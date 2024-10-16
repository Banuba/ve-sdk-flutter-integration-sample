import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ve_sdk/audio_browser.dart';
import 'package:image_picker/image_picker.dart';

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
  static const methodReleaseVideoEditor = 'releaseVideoEditor';
  static const methodDemoPlayExportedVideo = 'playExportedVideo';

  static const argExportedVideoFile = 'argExportedVideoFilePath';
  static const argExportedVideoCoverPreviewPath = 'argExportedVideoCoverPreviewPath';

  // For Photo Editor
  static const methodInitPhotoEditor = 'initPhotoEditor';
  static const methodStartPhotoEditor = 'startPhotoEditor';
  static const argExportedPhotoFile = 'argExportedPhotoFilePath';

  static const platformChannel = MethodChannel('banubaSdkChannel');

  String _errorMessage = '';

  Future<void> _initPhotoEditor() async {
    if (Platform.isAndroid){
      await _releaseVideoEditor();
    }
    await platformChannel.invokeMethod(methodInitPhotoEditor, LICENSE_TOKEN);
  }

  Future<void> _startPhotoEditor() async {
    try {
      await _initPhotoEditor();

      dynamic result = await platformChannel.invokeMethod(methodStartPhotoEditor);

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
    await platformChannel.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
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

  Future<void> _releaseVideoEditor() async {
    try {
      await platformChannel.invokeMethod(methodReleaseVideoEditor);
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
            'The license is revoked or expired. Please contact Banuba https://www.banuba.com/support';
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
            Expanded(
              flex: 1,
              child: Center(
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'The sample demonstrates how to run Banuba Video and Photo Editor SDK with Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shadowColor: Colors.greenAccent,
                      elevation: 10,
                      fixedSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _startPhotoEditor(),
                    child: const Text(
                      'Open Photo Editor',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shadowColor: Colors.blueGrey,
                      elevation: 10,
                      fixedSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _startVideoEditorDefault(),
                    child: const Text(
                      'Open Video Editor - Default',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shadowColor: Colors.blueGrey,
                      elevation: 10,
                      fixedSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _startVideoEditorPIP(),
                    child: const Text(
                      'Open Video Editor - PIP',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shadowColor: Colors.blueGrey,
                      elevation: 10,
                      fixedSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shadowColor: Colors.redAccent,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => {Navigator.pop(context)},
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shadowColor: Colors.greenAccent,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
