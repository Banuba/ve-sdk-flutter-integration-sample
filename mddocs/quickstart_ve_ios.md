# iOS Video Editor SDK quickstart

This guide demonstrates how to quickly integrate iOS Video Editor SDK into Flutter project.
The main part of an integration and customization is implemented in ```ios``` directory
of Flutter project using native iOS development process.

Once complete you will be able to launch video editor in your Flutter project.

- [Installation](#Installation)
- [Resources](#Resources)
- [Configuration](#Configuration)
- [Launch](#Launch)
- [Connect audio](#Connect-audio)
- [What is next?](#What-is-next)

## Installation
Add iOS Video Editor SDK dependencies to your [Podfile](../ios/Podfile)
```swift
  sdk_version = '1.34.0'

  pod 'BanubaARCloudSDK', sdk_version #optional
  pod 'BanubaVideoEditorSDK', sdk_version
  pod 'BanubaAudioBrowserSDK', sdk_version #optional
  pod 'BanubaSDK', sdk_version #optional
  pod 'BanubaSDKSimple', sdk_version
  pod 'BanubaSDKServicing', sdk_version
  pod 'VideoEditor', sdk_version
  pod 'BanubaUtilities', sdk_version
  pod 'BanubaVideoEditorGallerySDK', sdk_version #optional
  pod 'BanubaLicenseServicingSDK', sdk_version

  pod 'BNBLicenseUtils', sdk_version

  pod 'VEExportSDK', sdk_version
  pod 'VEEffectsSDK', sdk_version
  pod 'VEPlaybackSDK', sdk_version
```


## Resources
Video Editor SDK uses a lot of resources required for running.  
Please make sure all these resources are provided in your project.
1. [bundleEffects](../ios/bundleEffects) to use Banuba AR filters. requires [Face AR](https://docs.banuba.com/face-ar-sdk-v1) product.
2. [luts](../ios/luts) to use color filters(Lut).

## Configuration
Create new Swift class [VideoEditorModule](../ios/Runner/VideoEditorModule.swift) in your project
for initializing and customizing Video Editor SDK features.

IN PROGRESS - ADD Export media
Handle export [result](../lib/main.dart#L159)  where you can pass required data i.e. exported video stored to Flutter.

## Launch
[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) approach is used for communication between Flutter and iOS.

Set up channel message handler in your [AppDelegate.swift](../ios/Runner/AppDelegate.swift#54)
to listen to calls from Flutter.
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

Send [initialize](../lib/main.dart#L79) message from Flutter to iOS
```dart
  await platformChannel.invokeMethod('initVideoEditor', LICENSE_TOKEN);
```
and add corresponding [initialize](../ios/Runner/AppDelegate.swift#64) handler on iOS side to initialize Video Editor.

Initialize Video Editor SDK using license token in [VideoEditorModule](../ios/Runner/VideoEditorModule.swift#L39) on iOS.
```swift
let videoEditor = BanubaVideoEditor(
        token: token,
        ...
      )
```
Instance ```videoEditor``` is ```nil``` if the license token is incorrect. In this case you cannot use video editor and check your license token.

Finally, once the SDK in initialized you can send [start](../lib/main.dart#L83) message from Flutter to iOS

```dart
  final result = await platformChannel.invokeMethod('startVideoEditor');
```

and add the corresponding [start](../ios/Runner/AppDelegate.swift#70) handler on iOS side to start Video Editor.

:exclamation: Important  
It is highly recommended to [check the license](../ios/Runner/VideoEditorModule.swift#L110) before starting Video Editor.

## Connect audio

This is an optional section in integration process. In this section you will know how to connect audio to Video Editor.

### Connect Soundstripe
Set ```false``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#13) 
and specify
IN PROGRESS

### Connect Mubert
Request API key from [Mubert](https://mubert.com/).  
:exclamation:  Banuba is not responsible for providing Mubert API key.

Set ```false``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#13)
and specify
IN PROGRESS
Set Mubert API key [within the app](../ios/Runner/AppDelegate.swift#15) and [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#13)  to ```false```
for playing Mubert content in Video Editor Audio Browser.

### Connect External Audio API
Video Editor SDK allows to implement your experience of providing audio tracks for your users - custom Audio Browser.  

To check out the simplest experience you can set ```true``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#13)  
:exclamation: Video Editor SDK can play only files stored on device.


## What is next?
This quickstart guide has just covered how to quickly integrate iOS Video Editor SDK,
it is considered you managed to start video editor from your Flutter project.

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/ios/requirements) to know more about the SDK and complete full integration.