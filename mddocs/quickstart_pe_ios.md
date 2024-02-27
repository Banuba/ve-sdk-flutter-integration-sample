# iOS Photo Editor SDK quickstart

This guide demonstrates how to quickly integrate iOS Photo Editor SDK into your Flutter project.
The main part of an integration and customization is implemented in ```ios``` directory
in your Flutter project using native iOS development process.

Once complete you will be able to launch photo editor in your Flutter project.

- [Installation](#Installation)
- [Launch](#Launch)
- [What is next?](#What-is-next)

## Installation
Add iOS Photo Editor SDK dependencies to your [Podfile](../ios/Podfile)
```swift
  # Photo Editor
  pod 'BanubaPhotoEditorSDK', '1.1.1'
```

## Launch
[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) approach is used for communication between Flutter and Android.

Set up channel message handler in your [AppDelegate.swift](../ios/Runner/AppDelegate.swift#L42)
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

Send [start](../lib/main.dart#L65) message from Flutter to iOS
```dart
  dynamic result = await platformChannel.invokeMethod('startPhotoEditor', LICENSE_TOKEN);
```
and add corresponding [start](../ios/Runner/AppDelegate.swift#L101) handler on iOS side to start Photo Editor.

Initialize Photo Editor SDK using license token in [PhotoEditorModule](../ios/Runner/PhotoEditorModule.swift#L17) on iOS.
```swift
  photoEditorSDK = BanubaPhotoEditor(
    token: token,
    configuration: PhotoEditorConfig()
  )
```
Instance ```photoEditorSDK``` is ```nil``` if the license token is incorrect. In this case you cannot use photo editor and check your license token.

Start Photo Editor using launch config
```swift
  let launchConfig = PhotoEditorLaunchConfig(
    hostController: controller,
    entryPoint: .gallery
  )
  
  photoEditorSDK?.delegate = self
        
  photoEditorSDK?.getLicenseState(completion: { [weak self] isValid in
    guard let self else { return }
    if isValid {
      print("✅ License is active, all good")
      photoEditorSDK?.presentPhotoEditor(
        withLaunchConfiguration: launchConfig,
        completion: nil
      )
    } else {
      print("❌ License is either revoked or expired")
    }
  })
```

:exclamation: Important  
It is highly recommended to [check the license](../ios/Runner/PhotoEditorModule.swift#L36) before starting Photo Editor.

## What is next?
This quickstart guide has just covered how to quickly integrate iOS Photo Editor SDK,
it is considered you managed to start photo editor from your Flutter project.

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/ios/pe-requirements) to know more about the SDK and complete full integration.