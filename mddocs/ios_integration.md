# iOS Integration Guide into Flutter project

An integration and customization of Banuba Video Editor SDK is implemented in **ios** directory
of your Flutter project using native iOS development process.

## Basic
The following steps help to complete basic integration into your Flutter project.

<ins>All changes are made in **ios** directory.</ins>
1. __Set Banuba Video Editor SDK token__  
   Set Banuba token in the sample app [VideoEditor initializer](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift#L13).<br></br>
   To get access to your trial, please, get in touch with us by [filling a form](https://www.banuba.com/video-editor-sdk) on our website. Our sales managers will send you the trial token.<br>
   :exclamation: The token **IS REQUIRED** to run sample and an integration in your app.<br></br>

2. __Add Banuba Video Editor SDK dependencies__  
   Add iOS Video Editor SDK dependencies to your Podfile.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Podfile)</br><br>

3. __Add SDK Initializer class__  
   Add [VideoEditorModule.swift](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift) file to your project.
   This class helps to initialize and customize Video Editor SDK.</br><br>

4. __Setup platform channel to start Video Editor SDK__  
   Create ```FlutterMethodChannel``` in your ```AppDelegate``` instance to start ```VideoEditorModule```.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L14)</br>
   Find more information about platform channels in [Flutter developer documentation](https://docs.flutter.dev/development/platform-integration/platform-channels).</br><br>

5. __Add assets and resources__  
   1. [bundleEffects](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/bundleEffects) to use build-in Banuba AR effects. Using Banuba AR requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.
   2. [luts](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/luts) to use Lut effects shown in the Effects tab.</br><br>

6. __Start Video Editor SDK__  
   Use ```platform.invokeMethod``` to start Video Editor SDK from Flutter.</br>
   ```dart
      Future<void> _startVideoEditorIos() async {
      try {
        final result = await platform.invokeMethod('openVideoEditor');
        debugPrint('Result: $result ');
      } on PlatformException catch (e) {
        debugPrint("Error: '${e.message}'.");
      }
    }
   ```
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/lib/main.dart#L102)</br>


## What is next?

We have covered a basic process of Banuba Video Editor SDK integration into your Flutter project.</br>
More details and customization options you will find in [Banuba Video Editor SDK iOS Integration Sample](https://github.com/Banuba/ve-sdk-ios-integration-sample).