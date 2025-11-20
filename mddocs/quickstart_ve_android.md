# Android Video Editor SDK quickstart

This guide demonstrates how to quickly integrate Android Video Editor SDK into Flutter project.
The main part of an integration and customization is implemented in ```android``` directory
of Flutter project using native Android development process.

Once complete you will be able to launch video editor in your Flutter project.

- [Installation](#Installation)
- [Resources](#Resources)
- [Configuration](#Configuration)
- [Launch](#Launch)
- [Editor V2](#Editor-v2)
- [Face AR Effects](#Face-AR-Effects)
- [Connect audio](#Connect-audio)
- [What is next?](#What-is-next)

## Installation
GitHub Packages is used for downloading Android Video Editor SDK modules.

Add repositories to [gradle](../android/build.gradle#L1) file in ```allprojects``` section.

```groovy
allprojects {
   repositories {
      maven {
         name = "nexus"
         url = uri("https://nexus.banuba.net/repository/maven-releases")
      }
   }
}
```

Specify the following ```packaging options``` in your [build gradle](../android/app/build.gradle#L63-L71) file:
```groovy
android {
...
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
...
}
```

Specify a list of dependencies in [gradle](../android/app/build.gradle#L83) file.
```groovy
    def banubaSdkVersion = '1.48.5'
    implementation "com.banuba.sdk:ffmpeg:5.3.0"
    implementation "com.banuba.sdk:camera-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:camera-ui-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:core-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:core-ui-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-flow-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-ui-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-gallery-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-effects-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:effect-player-adapter:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ar-cloud:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-audio-browser-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-export-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-playback-sdk:${banubaSdkVersion}"
```

Additionally, make sure the following plugins are in your app [gradle](../android/app/build.gradle#L1) and at the top of the file.
```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "kotlin-parcelize"
}
```

## Resources
Video Editor SDK uses a lot of resources required for running in the app.  
Please make sure all these resources exist in your project.

1. [drawable-xhdpi](../android/app/src/main/res/drawable-xhdpi),
   [drawable-xxhdpi](../android/app/src/main/res/drawable-xxhdpi),
   [drawable-xxxhdpi](../android/app/src/main/res/drawable-xxxhdpi) are visual assets for color filter previews.

2. [styles.xml](../android/app/src/main/res/values/styles.xml) includes implementation of ```VideoCreationTheme``` of Video Editor SDK.

## Configuration

Next, specify ```VideoCreationActivity``` in your [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L53).
This Activity combines a number of screens into video editor flow.

```xml
<activity
android:name="com.banuba.sdk.ve.flow.VideoCreationActivity"
android:screenOrientation="portrait"
android:theme="@style/CustomIntegrationAppTheme"
android:windowSoftInputMode="adjustResize"
tools:replace="android:theme" />
```

Next, allow Network by adding permissions
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```
and ```android:usesCleartextTraffic="true"``` in [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml).

Network access is used for downloading AR effects from AR Cloud and stickers from [Giphy](https://giphy.com/).

Please set up correctly [network security config](https://developer.android.com/training/articles/security-config) and use of ```android:usesCleartextTraffic```
by following [guide](https://developer.android.com/guide/topics/manifest/application-element).  

Create new Kotlin class [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt) in your project
for initializing and customizing Video Editor SDK features.

### Export media
Video Editor SDK exports single video with auto quality by default. Auto quality is based on device hardware capabilities.

Every exported media is passed to  [onActivityResult](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#236) method. 
Process the result and pass it to [handler](../lib/main.dart#L189) on Flutter side.

## Launch
[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) approach is used for communication between Flutter and Android.

Set up channel message handler in your [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L71) 
to listen to calls from Flutter.
```kotlin
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        ...
        val appFlutterEngine = requireNotNull(flutterEngine)
        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            "banubaSdkChannel"
        ).setMethodCallHandler { call, result ->
            // Handle method calls
        }
    }
}
```

Send [initVideoEditor](../lib/main.dart#L90) message from Flutter to Android

```dart
  await platformChannel.invokeMethod('initVideoEditor', LICENSE_TOKEN);
```

and add corresponding [handler](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L79) on Android side to initialize Video Editor.

```kotlin
 val licenseToken = call.arguments as String
 val editorSDK = BanubaVideoEditor.initialize(licenseToken)

if (editorSDK == null) {
    // The SDK token is incorrect - empty or truncated
    ...
} else {
    if (videoEditorModule == null) {
        // Initialize video editor sdk dependencies
        videoEditorModule = VideoEditorModule().apply {
            initialize(application)
        }
    }
   ...
}

```

Finally, once the SDK in initialized you can send [startVideoEditor](../lib/main.dart#L97) message from Flutter to Android

```dart
  final result = await platformChannel.invokeMethod('startVideoEditor');
```

and add the corresponding [handler](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L97) on Android side to start Video Editor.

> [!IMPORTANT]
> 1. Instance ```videoEditorSDK``` is ```null``` if the license token is incorrect. In this case you cannot use photo editor. Check your license token.
> 2. It is highly recommended to [check](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L332) if the license is active before starting Photo Editor.

## Editor V2

To keep up with the latest developments and best practices, our team has completely redesigned the Video Editor SDK to be as convenient and enjoyable as possible.

### Integration

Create ```Bundle``` with Editor UI V2 configuration and pass [extras](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#68) to any [Video Editor start method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#277).

```kotlin
 val extras = bundleOf(
    "EXTRA_USE_EDITOR_V2" to true
 )
```

## Face AR Effects

[Banuba Face AR SDK product](https://www.banuba.com/facear-sdk/face-filters) is used on camera and editor screens for applying various AR effects while making video content.
Any Face AR effect is a folder that includes a number of files required for Face AR SDK to play this effect.

> [!NOTE]
> Make sure preview.png file is included in effect folder. You can use this file as a preview for AR effect.

There are 3 options for adding and managing AR effects:

1. Store all effects by the path [assets/bnb-resources/effects](../android/app/src/main/assets/bnb-resources/) folder in the app.
2. Store color effects in [assets/bnb-resources/luts](../android/app/src/main/assets/bnb-resources/luts) folder in the app.
3. Use [AR Cloud](https://www.banuba.com/faq/what-is-ar-cloud) for storing effects on a server.

## Connect audio

This is an optional section in integration process. In this section you will know how to connect audio to Video Editor.  

### Connect Soundstripe
Set ```false``` in [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34) 
and specify ```SoundstripeProvider``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L72)

> [!IMPORTANT]
> The feature is not activated by default. Please, contact Banuba representatives to know more about using this feature.

```kotlin
single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")){
   SoundstripeProvider()
}
```
to use audio from [Soundstripe](https://www.soundstripe.com/) in Video Editor.

### Connect Mubert

Request API key from [Mubert](https://mubert.com/).  
> [!MPORTANT]
> Banuba is not responsible for providing Mubert API key.

Set ```false``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34) 
and specify ```MubertApiConfig``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L72)

```kotlin
single {
   MubertApiConfig(
      mubertLicence = "...",
      mubertToken = "..."
   )
}

single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")) {
   AudioBrowserMusicProvider()
}
```
to use audio from [Mubert](https://mubert.com/) in Video Editor.

### Connect Banuba Music

Set ```false``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34)
and specify ```BanubaMusicProvider``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L72)

> [!IMPORTANT]
> The feature is not activated by default. Please, contact Banuba representatives to know more about using this feature.

```kotlin
single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")){
   BanubaMusicProvider()
}
```
to use audio from ```Banuba Music``` in Video Editor.

### Connect External Audio API

Video Editor SDK allows to implement your experience of providing audio tracks using [External Audio API](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content#connect-external-api).  
To check out the simplest experience on Flutter you can set ```true``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34)  

> [!IMPORTANT]  
> Video Editor SDK can play only audio tracks stored on the device.

More information is available in our [audio content](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content) guide.

## What is next?

This quickstart guide has just covered how to quickly integrate Android Video Editor SDK, it is considered you managed to start video editor from your Flutter project. 

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-ve/) to know more about the SDK and complete full integration.