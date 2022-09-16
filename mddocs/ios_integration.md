# iOS Integration Guide into Flutter project

An integration and customization of Banuba Video Editor UI SDK is implemented in **ios** directory
of your Flutter project using native iOS development process.

## Basic
The following steps help to complete basic integration into your project.

<ins>All changes are made in **ios** directory.</ins>
1. __Add Banuba Video Editor UI SDK dependencies__  
   Add iOS Video Editor UI SDK dependencies to your Podfile.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Podfile).</br><br>

2. __Add SDK Initializer class__  
   Add [VideoEditorModule.swift](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift) file to your project.
   This class helps to initialize and customize Video Editor UI SDK.</br><br>

3. __Setup platform channel to start the SDK__  
   Create ```FlutterMethodChannel``` in your ```AppDelegate``` instance to start ```VideoEditorModule```.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L14).</br>
   Find more information about platform channels in [Flutter developer documentation](https://docs.flutter.dev/development/platform-integration/platform-channels).</br><br>

4. __Add assets and resources__  
   1. [bundleEffects](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/bundleEffects) to use build-in Banuba AR effects. Using Banuba AR requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.
   2. [luts](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/luts) to use Lut effects shown in the Effects tab.</br><br>

5. __Start the SDK__  
   Use ```platform.invokeMethod``` method defined in **step 2** to start the SDK from Flutter.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/lib/main.dart).</br>


## What is next?

We have covered a basic process of VE UI SDK integration into your Flutter project.</br>
More details and customization options you will find in [Banuba Video Editor UI SDK Integration Sample](https://github.com/Banuba/ve-sdk-ios-integration-sample).