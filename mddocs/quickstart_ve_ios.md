# iOS Video Editor SDK quickstart

This guide demonstrates how to quickly integrate iOS Video Editor SDK into Flutter project.
The main part of an integration and customization is implemented in ```ios``` directory
of Flutter project using native iOS development process.

Once complete you will be able to launch video editor in your Flutter project.

- [Installation](#Installation)
- [Resources](#Resources)
- [Configuration](#Configuration)
- [Launch](#Launch)
- [Face AR Effects](#Face-AR-Effects)
- [Connect audio](#Connect-audio)
- [What is next?](#What-is-next)

## Installation

Add iOS Video Editor SDK dependencies to your [Podfile](../ios/Podfile)
```swift
  sdk_version = '1.37.0'

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

1. [luts](../ios/luts) to use color filters(Lut).
2. [Localizable.strings](../ios/Runner/en.lproj/Localizable.strings) file with English localization.

## Configuration
Create new Swift class [VideoEditorModule](../ios/Runner/VideoEditorModule.swift) in your project
for initializing and customizing Video Editor SDK features.

### Export media
Video Editor supports exporting multiple media files to meet your product requirements.

Create video URL where to export video file.
```swift
   let videoURL = manager.temporaryDirectory.appendingPathComponent("myAwesomeVideo.mov")
```
Next, create list of ```ExportVideoConfiguration``` where each configuration is exported media file
```diff
     let exportVideoConfigurations: [ExportVideoConfiguration] = [
 +           ExportVideoConfiguration(
                fileURL: videoURL,
                quality: .auto,
                useHEVCCodecIfPossible: true,
                watermarkConfiguration: nil
            )
        ]
```
and set this list to ```ExportConfiguration```
```diff
    let exportConfiguration = ExportConfiguration(
+            videoConfigurations: exportVideoConfigurations,
            isCoverEnabled: true,
            gifSettings: nil
    )
```
Finally, start video export
```diff
+    videoEditorSDK?.export(
            using: exportConfiguration,
            exportProgress: { [weak progressView] progress in progressView?.updateProgressView(with: Float(progress)) }
        ) { [weak self] (error, coverImage) in
            // Export Callback
            DispatchQueue.main.async {
                progressView.dismiss(animated: true) {
                    // if export cancelled just hide progress view
                    if let error, error as NSError == exportCancelledError {
                        return
                    }
                    self?.completeExport(videoUrl: firstFileURL, error: error, coverImage: coverImage?.coverImage)
                }
            }
        }
```
Every exported media is passed to  [completeExport](../ios/Runner/VideoEditorModule.swift#L193) method.
Process the result and pass it to [handler](../lib/main.dart#L189) on Flutter side.

Please [check out](../ios/Runner/VideoEditorModule.swift#L143) full export sample.

## Launch

[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) approach is used for communication between Flutter and iOS.

Set up channel message handler in your [AppDelegate.swift](../ios/Runner/AppDelegate.swift#42)
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

Send [initVideoEditor](../lib/main.dart#L97) message from Flutter to iOS
```dart
  await platformChannel.invokeMethod('initVideoEditor', LICENSE_TOKEN);
```
and add corresponding [handler](../ios/Runner/AppDelegate.swift#L55) on iOS side to initialize Video Editor.

Initialize Video Editor SDK using license token in [VideoEditorModule](../ios/Runner/VideoEditorModule.swift#L41) on iOS.
```swift
  let videoEditor = BanubaVideoEditor(
    token: token,
    ...
  )
```
Finally, once the SDK in initialized you can send [startVideoEditor](../lib/main.dart#L97) message from Flutter to iOS

```dart
  final result = await platformChannel.invokeMethod('startVideoEditor');
```

and add the corresponding [handler](../ios/Runner/AppDelegate.swift#59) on iOS side to start Video Editor.

> [!IMPORTANT]
> 1. Instance ```videoEditor``` is ```nil``` if the license token is incorrect. In this case you cannot use photo editor. Check your license token.
> 2. It is highly recommended to [check](../ios/Runner/VideoEditorModule.swift#L106) if the license if active before starting Video Editor.

## Face AR Effects

[Banuba Face AR SDK product](https://www.banuba.com/facear-sdk/face-filters) is used on camera and editor screens for applying various AR effects while making video content.
Any Face AR effect is a folder that includes a number of files required for Face AR SDK to play this effect.

> [!NOTE]
> Make sure preview.png file is included in effect folder. You can use this file as a preview for AR effect.

There are 2 options for adding and managing AR effects:

1. Add ```bundleEffects``` folder in the [project](../ios/) and place effects there.
2. Use [AR Cloud](https://www.banuba.com/faq/what-is-ar-cloud) for storing effects on a server.

## Connect audio

This is an optional section in integration process. In this section you will know how to connect audio to Video Editor.

### Connect Soundstripe
Set ```false``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#L13) and ```.soundstripe``` to ```AudioBrowserConfig.shared.musicSource``` [config](../ios/Runner/AppDelegate.swift#L148) 
to use audio from [Soundstripe](https://www.soundstripe.com/) in Video Editor.

> [!IMPORTANT]
> The feature is not activated by default. Please, contact Banuba representatives to know more about using this feature.

### Connect Mubert
Request API key from [Mubert](https://mubert.com/).  

> [!IMPORTANT]  
> Banuba is not responsible for providing Mubert API key.

For playing Mubert content in Video Editor Audio Browser perform the following steps:

1. Set ```false``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#L13)
2. Set Mubert API license and key [within the app](../ios/Runner/AppDelegate.swift#L147)
3. Set ```.allSources``` to ```AudioBrowserConfig.shared.musicSource``` [config](../ios/Runner/AppDelegate.swift#L148)

### Connect Banuba Music

Set ```false``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#L13) and ```.banubaMusic``` to ```AudioBrowserConfig.shared.musicSource``` [config](../ios/Runner/AppDelegate.swift#L148) 
to use audio ```Banuba Music``` in Video Editor.

> [!IMPORTANT]
> The feature is not activated by default. Please, contact Banuba representatives to know more about using this feature.

### Connect External Audio API

Video Editor SDK allows to implement your experience of providing audio tracks for your users - custom Audio Browser.  

To check out the simplest experience you can set ```true``` to [configEnableCustomAudioBrowser](../ios/Runner/AppDelegate.swift#L13)  
:exclamation: Video Editor SDK can play only files stored on device.

## What is next?
This quickstart guide has just covered how to quickly integrate iOS Video Editor SDK,
it is considered you managed to start video editor from your Flutter project.

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/ios/requirements) to know more about the SDK and complete full integration.