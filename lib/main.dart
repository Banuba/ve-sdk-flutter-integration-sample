import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: directives_ordering
import 'dart:io' show Platform;

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
      home: MyHomePage(title: 'Banuba VE SDK Sample Integration'),
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
                'The sample demonstrates how Banuba Video Editor SDK can be integrated to Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'The sample demonstrates how Banuba Video Editor SDK can be integrated to Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                    ))),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              onPressed: () {
                if (Platform.isAndroid) {
                  _startVideoEditorActivity();
                } else if (Platform.isIOS) {
                  _startIOSVideoEditorActivity();
                } else {
                  _showAlert(context, 'Platform is not supported!');
                }
              },
              child: const Text(
                'Open Video Editor',
                style: TextStyle(
                  fontSize: 18.0,
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

  Future<void> _startIOSVideoEditorActivity() async {
    try {
      final result = await platform.invokeMethod('openVideoEditor');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }

  Future<void> _startVideoEditorActivity() async {
    try {
      final result = await platform.invokeMethod('StartBanubaVideoEditor');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }
}
