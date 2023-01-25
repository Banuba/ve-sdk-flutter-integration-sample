# iOS integration guide into Flutter project

The following guide covers basic integration process into your Flutter project
where required part of an integration and customization of Banuba Video Editor SDK is implemented in **ios** directory
of your Flutter project using native iOS development process.

### Prerequisite
:exclamation: The license token **IS REQUIRED** to run sample and an integration into your app.  
Please follow [Installation](../README.md#Installation) guide if the license token is not set.

### Add SDK dependencies
Add iOS Video Editor SDK dependencies to your [Podfile](../ios/Podfile)

### Add SDK integration module
Add [VideoEditorModule.swift](../ios/Runner/VideoEditorModule.swift) file
to initialize SDK dependencies. This class also allows you to customize many Video Editor SDK features i.e. min/max video durations, export flow, order of effects and others.

### Add resources
Video Editor SDK uses a lot of resources required for running.  
Please make sure all these resources are provided in your project.
1. [bundleEffects](../ios/bundleEffects) to use build-in Banuba AR effects. Using Banuba AR requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.
2. [luts](../ios/luts) to use Lut effects shown in the Effects tab.

### Add platform channel
[Platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) is used for communication between Flutter and iOS.

Add channel message handler to your [AppDelegate.swift]((../ios/Runner/AppDelegate.swift#54))
to listen to calls from Flutter side. Flutter sends messages in this channel to initialize or start Video Editor.
```swift
    let binaryMessenger = controller as? FlutterBinaryMessenger {
            
    let channel = FlutterMethodChannel(
        name: AppDelegate.channelName,
        binaryMessenger: binaryMessenger
    )
            
     channel.setMethodCallHandler { methodCall, result in
     ... 
     }
```

### Start SDK
First, initialize Video Editor SDK using license token in [VideoEditorModule](../ios/Runner/VideoEditorModule.swift#L30) on iOS.
```swift
let videoEditor = BanubaVideoEditor(
        token: token,
        ...
      )
```
Please note, instance ```videoEditor``` can be **nil** if the license token is incorrect.

Next, to start Video Editor SDK from Flutter use ```platform.invokeMethod``` method from [Flutter](../lib/main.dart#L79).
It will open Video Editor SDK from camera screen.

```dart
    Future<void> _initVideoEditor() async {
        await platform.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
    }
   
    Future<void> _startVideoEditorDefault() async {
        try {
          await _initVideoEditor();
          final result = await platform.invokeMethod('StartBanubaVideoEditor');
          ...
          } on PlatformException catch (e) {
            debugPrint("Error: '${e.message}'.");
         }
    }
   ```
Export returns [result](../lib/main.dart#L79)  where you can pass required data i.e. exported video stored to Flutter.

### Enable custom Audio Browser experience
Video Editor SDK allows to implement your experience of providing audio tracks for your users - custom Audio Browser.  
To check out the simplest experience you can set ```true``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#12)  
:exclamation: Video Editor SDK can play only files stored on device.

### Connect Mubert
:exclamation: Please request API key from [Mubert](https://mubert.com/). Banuba is not responsible for providing Mubert API key.  
Set Mubert API key [within the app](../ios/Runner/AppDelegate.swift#15) and [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#12)  to ```false```
for playing Mubert content in Video Editor Audio Browser.

## What is next?
We have covered a basic process of Banuba Video Editor SDK integration into your Flutter project.</br>
More details and customization options you will find in [Banuba Video Editor SDK iOS Integration Sample](https://github.com/Banuba/ve-sdk-ios-integration-sample).