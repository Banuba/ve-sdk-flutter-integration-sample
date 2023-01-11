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
      home: MyHomePage(title: 'Banuba Video Editor SDK Sample'),
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
  static const channelName = 'startActivity/VideoEditorChannel';

  static const methodStartVideoEditor = 'StartBanubaVideoEditor';
  static const methodStartVideoEditorPIP = 'StartBanubaVideoEditorPIP';
  static const methodStartVideoEditorTrimmer = 'StartBanubaVideoEditorTrimmer';
  static const methodDemoPlayExportedVideo = 'PlayExportedVideo';

  static const errMissingExportResult = 'ERR_MISSING_EXPORT_RESULT';
  static const errStartPIPMissingVideo = 'ERR_START_PIP_MISSING_VIDEO';
  static const errStartTrimmerMissingVideo = 'ERR_START_TRIMMER_MISSING_VIDEO';
  static const errExportPlayMissingVideo = 'ERR_EXPORT_PLAY_MISSING_VIDEO';

  static const errEditorNotInitializedCode = 'ERR_VIDEO_EDITOR_NOT_INITIALIZED';
  static const errEditorNotInitializedMessage =
      'Banuba Video Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba';
  static const errEditorLicenseRevokedCode = 'ERR_VIDEO_EDITOR_LICENSE_REVOKED';
  static const errEditorLicenseRevokedMessage =
      'License is revoked or expired. Please contact Banuba https://www.banuba.com/faq/kb-tickets/new';

  static const argExportedVideoFile = 'exportedVideoFilePath';

  static const platform = MethodChannel(channelName);

  String _errorMessage = '';

  Future<void> _startVideoEditorDefault() async {
    try {
      final result = await platform.invokeMethod(methodStartVideoEditor);

      _handleExportResult(result);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  void _handleExportResult(dynamic result) {
    debugPrint('Export result = $result');

    // You can use any kind of export result passed from platform.
    // Map is used for this sample to demonstrate playing exported video file.
    if (result is Map) {
      final exportedVideoFilePath = result[argExportedVideoFile];
      _showConfirmation(context, "Play exported video file?", () {
        platform.invokeMethod(methodDemoPlayExportedVideo, exportedVideoFilePath);
      });
    }
  }

  Future<void> _startVideoEditorPIP() async {
    try {
      // Use your implementation to provide correct video file path to start Video Editor SDK in PIP mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint('Cannot open video editor with PIP - video was not selected!');
      } else {
        debugPrint('Open video editor in pip with video = ${file.path}');
        final result = await platform.invokeMethod(methodStartVideoEditorPIP, file.path);

        _handleExportResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _startVideoEditorTrimmer() async {
    try {
      // Use your implementation to provide correct video file path to start Video Editor SDK in Trimmer mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint('Cannot open video editor with Trimmer - video was not selected!');
      } else {
        debugPrint('Open video editor in trimmer with video = ${file.path}');
        final result = await platform.invokeMethod(methodStartVideoEditorTrimmer, file.path);

        _handleExportResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
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
                'The sample demonstrates how to run Banuba Video Editor SDK with Flutter',
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
              color: Colors.green,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              splashColor: Colors.greenAccent,
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
              color: Colors.red,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              splashColor: Colors.redAccent,
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

  // Handle exceptions thrown on Android, iOS platform while opening Video Editor SDK
  void _handlePlatformException(PlatformException exception) {
    debugPrint("Error: '${exception.message}'.");

    String errorMessage = '';
    switch (exception.code) {
      case errEditorLicenseRevokedCode:
        errorMessage = errEditorLicenseRevokedMessage;
        break;
      case errEditorNotInitializedCode:
        errorMessage = errEditorNotInitializedMessage;
        break;
      default:
        errorMessage = 'unknown error';
    }

    _errorMessage = errorMessage;
    setState(() {});
  }

  void _showConfirmation(
      BuildContext context,
      String message,
      VoidCallback block
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo'),
        content: Text(message),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.redAccent,
            onPressed: () => { Navigator.pop(context) },
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
