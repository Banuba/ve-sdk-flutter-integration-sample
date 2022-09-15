# iOS Integration Guide into Flutter project

Take the following steps to complete the basic integration in your project. All changes are made in **ios** directory.

1. __Add the Banuba SDK dependencies__  
Add necessary VE SDK libraries to your Podfile. [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Podfile).
2. __Copy the SDK wrapper class__  
Copy the [VideoEditorModule.swift](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift) file to your project.
3. __Setup the platform channel to show the Video Editor__  
Create the ```FlutterMethodChannel``` in your ```AppDelegate``` instance to invoke the ```VideoEditorModule``` at a later point of time. [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L14). More information about platform channels can be found at [Flutter developer documentation](https://docs.flutter.dev/development/platform-integration/platform-channels).
4. __Copy the effect assets__  
The [bundleEffects](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/bundleEffects) folder contains built-in AR Masks. Using Banuba AR requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.
The [luts](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/luts) folder contains bitmaps shown in the Effects tab.
5. __Start the SDK__  
To present the VE UI from your Flutter app invoke the platform method previously defined at step 2 via the ```platform.invokeMethod``` method. [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/lib/main.dart)

# What is next?

We have covered a basic process of VE UI SDK integration into your project. More details and customization options can be found in our native [VE UI SDK Integration Sample](https://github.com/Banuba/ve-sdk-ios-integration-sample).