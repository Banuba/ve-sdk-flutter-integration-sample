import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Banuba VE SDK Sample'),
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
  static const platform = MethodChannel('startActivity/VideoEditorChannel');

  Future<void> _startVideoEditorDefault() async {
    try {
      final result = await platform.invokeMethod('StartBanubaVideoEditor');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
      _showAlert(context, 'Platform is not supported!');
    }
  }

  Future<void> _startVideoEditorPIP() async {
    try {
      // Use your implementation to provide correct video file path to Video Editor SDK
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint('Cannot open video editor with PIP - video was not selected!');
      } else {
        debugPrint('Open video editor in pip with video = ${file.path}');
        final result = await platform.invokeMethod('StartBanubaVideoEditorPIP', file.path);
        debugPrint('Result: $result ');
      }
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
      _showAlert(context, 'Platform is not supported!');
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
              padding: EdgeInsets.all(16.0),
              child: Text(
                'The sample demonstrates how to run Banuba Video Editor SDK with Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
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
              onPressed: () => _startVideoEditorDefault(),
              child: const Text(
                'Open Video Editor - Default',
                style: TextStyle(
                  fontSize: 17.0,
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
              onPressed: () => _startVideoEditorPIP(),
              child: const Text(
                'Open Video Editor - PIP',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAlert(
    BuildContext context,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attention'),
        content: Text(message),
      ),
    );
  }
}
