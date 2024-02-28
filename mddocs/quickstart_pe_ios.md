# iOS Photo Editor SDK quickstart

This guide demonstrates how to quickly integrate iOS Photo Editor SDK into your Flutter project.
The main part of an integration and customization is implemented in ```ios``` directory
in your Flutter project using native iOS development process.

Once complete you will be able to launch photo editor in your Flutter project.

- [Installation](#Installation)
- [Configuration](#configuration)
- [Launch](#Launch)
- [What is next?](#What-is-next)

## Installation
Add iOS Photo Editor SDK dependencies to your [Podfile](../ios/Podfile)
```swift
  # Photo Editor
  pod 'BanubaPhotoEditorSDK', '1.1.1'
```

## Configuration
Create new Swift class [PhotoEditorModule](../ios/Runner/PhotoEditorModule.swift) in your project for initializing and customizing Photo Editor SDK features.

## Launch

[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) approach is used for communication between Flutter and iOS.

Set up channel message handler in your [AppDelegate](../ios/Runner/AppDelegate.swift#L42) to listen to calls from Flutter.
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

Send [startPhotoEditor](../lib/main.dart#L65) message from Flutter to iOS
```dart
  dynamic result = await platformChannel.invokeMethod('startPhotoEditor', LICENSE_TOKEN);
```
and add corresponding [handler](../ios/Runner/AppDelegate.swift#L101) on iOS side to start Photo Editor,  
where at first [initialize](../ios/Runner/PhotoEditorModule.swift#L17) Photo Editor using the license token and ```PhotoEditorConfig``` 
```swift
    let photoEditorSDK = BanubaPhotoEditor(
        token: token,
        configuration: PhotoEditorConfig()
    )
```

and finally [start](../ios/Runner/PhotoEditorModule.swift#L40) Photo Editor in ```PhotoEditorModule```.
```diff
+ let launchConfig = PhotoEditorLaunchConfig(
    hostController: controller,
    entryPoint: .gallery
  )
  
  photoEditorSDK?.delegate = self
        
  photoEditorSDK?.getLicenseState(completion: { [weak self] isValid in
    guard let self else { return }
    if isValid {
      print("✅ License is active, all good")
+      photoEditorSDK?.presentPhotoEditor(
        withLaunchConfiguration: launchConfig,
        completion: nil
      )
    } else {
      print("❌ License is either revoked or expired")
    }
  })
```

:exclamation: Important  
1. Instance ```photoEditorSDK``` is ```nil``` if the license token is incorrect. In this case you cannot use photo editor. Check your license token.
2. It is highly recommended to [check](../ios/Runner/PhotoEditorModule.swift#L104) if the license if active before starting Photo Editor.

## What is next?
This quickstart guide has just covered how to quickly integrate iOS Photo Editor SDK,
it is considered you managed to start photo editor from your Flutter project.

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/ios/pe-requirements) to know more about the SDK and complete full integration.