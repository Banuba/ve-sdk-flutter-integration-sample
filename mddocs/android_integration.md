# Android Video Editor SDK quickstart

- [Overview](#Overview)
- [Installation](#Installation)
- [Resources](#Resources)
- [Configuration](#Configuration)
- [Launch](#Launch)
- [Connect audio](#Connect-audio)
- [What is next?](#What-is-next)

## Overview
The following quickstart guide demonstrates you how to quickly integrate Android Video Editor SDK into your Flutter project.
The main part of an integration and customization is implemented in ```android``` directory
in your Flutter project using native Android development process. 

Once complete you will be able to launch video editor in your Flutter project.

## Installation
Add Banuba repositories to [gradle](../android/build.gradle#L15) file in ```allprojects``` section to get SDK dependencies.

```groovy
...

allprojects {
    repositories {
        ...

        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/Banuba/banuba-ve-sdk")
            credentials {
                username = "Banuba"
                password = "\u0038\u0036\u0032\u0037\u0063\u0035\u0031\u0030\u0033\u0034\u0032\u0063\u0061\u0033\u0065\u0061\u0031\u0032\u0034\u0064\u0065\u0066\u0039\u0062\u0034\u0030\u0063\u0063\u0037\u0039\u0038\u0063\u0038\u0038\u0066\u0034\u0031\u0032\u0061\u0038"
            }
        }
        maven {
            name = "ARCloudPackages"
            url = uri("https://maven.pkg.github.com/Banuba/banuba-ar")
            credentials {
                username = "Banuba"
                password = "\u0038\u0036\u0032\u0037\u0063\u0035\u0031\u0030\u0033\u0034\u0032\u0063\u0061\u0033\u0065\u0061\u0031\u0032\u0034\u0064\u0065\u0066\u0039\u0062\u0034\u0030\u0063\u0063\u0037\u0039\u0038\u0063\u0038\u0038\u0066\u0034\u0031\u0032\u0061\u0038"
            }
        }
        maven {
            name "GitHubPackagesEffectPlayer"
            url "https://maven.pkg.github.com/sdk-banuba/banuba-sdk-android"
            credentials {
                username = "sdk-banuba"
                password = "\u0067\u0068\u0070\u005f\u0033\u0057\u006a\u0059\u004a\u0067\u0071\u0054\u0058\u0058\u0068\u0074\u0051\u0033\u0075\u0038\u0051\u0046\u0036\u005a\u0067\u004f\u0041\u0053\u0064\u0046\u0032\u0045\u0046\u006a\u0030\u0036\u006d\u006e\u004a\u004a"
            }
        }

        ...
    }
}
```

Specify Video Editor SDK dependencies in the app [gradle](../android/app/build.gradle#L77) file.
```groovy
    def banubaSdkVersion = '1.34.0'
    implementation "com.banuba.sdk:ffmpeg:5.1.3"
    implementation "com.banuba.sdk:camera-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:camera-ui-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:core-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:core-ui-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-flow-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-timeline-sdk:${banubaSdkVersion}"
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

Additionally, make sure the following plugins are in your app [gradle](../android/app/build.gradle#L24) file.
```groovy
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'kotlin-parcelize'
```

## Resources
Video Editor SDK uses a lot of resources required for running in the app.  
Please make sure all these resources exist in your project.

1. [bnb-resources](../android/app/src/main/assets/bnb-resources)  Banuba AR and color filters. AR effects ```assets/bnb-resources/effects``` requires [Face AR](https://docs.banuba.com/face-ar-sdk-v1) product.

2. [drawable-hdpi](../android/app/src/main/res/drawable-hdpi),
   [drawable-xhdpi](../android/app/src/main/res/drawable-xhdpi),
   [drawable-xxhdpi](../android/app/src/main/res/drawable-xxhdpi),
   [drawable-xxxhdpi](../android/app/src/main/res/drawable-xxxhdpi) are visual assets for color filter previews.

3. [styles.xml](../android/app/src/main/res/values/styles.xml) includes implementation of ```VideoCreationTheme``` of Video Editor SDK.

## Configuration
Create new Kotlin class [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt) in your project. 
This class will be responsible for initializing and customizing Video Editor SDK features.

Next, specify ```VideoCreationActivity``` in your [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L53).
This Activity combines a number of screens into video editor flow.  
:exclamation:  Important

```xml
<activity
android:name="com.banuba.sdk.ve.flow.VideoCreationActivity"
android:screenOrientation="portrait"
android:theme="@style/CustomIntegrationAppTheme"
android:windowSoftInputMode="adjustResize"
tools:replace="android:theme" />
```

Allow Network access by adding permissions
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```
and ```android:usesCleartextTraffic="true"``` in [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml).

Network access is used for downloading AR effects from AR Cloud and stickers from [Giphy](https://giphy.com/).

Please set up correctly [network security config](https://developer.android.com/training/articles/security-config) and use of ```android:usesCleartextTraffic```
by following [guide](https://developer.android.com/guide/topics/manifest/application-element).  

### Export media
Video Editor SDK supports exporting multiple media files to meet your product requirements.
Create class [CustomExportParamsProvider](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L132) 
and implement ```ExportParamsProvider``` to provide ```List<ExportParams>``` where every ```ExportParams``` is a media file i.e. video or audio.

Use ```ExportParams.Builder.fileName``` method to set custom media file name.

Finally, handle export result in [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#237) and
pass the result to [Flutter](../lib/main.dart#L80).

## Launch
[Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) are used for communication between Flutter and Android.

Add channel message handler to your [FlutterActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L70) 
to listen to calls from Flutter side. Flutter sends messages in this channel to initialize and starts video editor.
```kotlin
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        ...
        val appFlutterEngine = requireNotNull(flutterEngine)
        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            "CHANNEL"
        ).setMethodCallHandler { call, result ->
            // Handle method calls
        }
    }
}
```

Flutter should send [init channel message](../lib/main.dart#L77) to Android to initialize Video Editor SDK using ```platform.invokeMethod```.
```dart
 Future<void> _initBanubaSdk() async {
    await platform.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
  }
```
Add channel message handler on Android side to initialize Video Editor SDK
```diff
MethodChannel(
    appFlutterEngine.dartExecutor.binaryMessenger,
    CHANNEL
).setMethodCallHandler { call, result ->

    when (call.method) {
        METHOD_INIT_VIDEO_EDITOR -> {
            val licenseToken = call.arguments as String
+            editorSDK = BanubaVideoEditor.initialize(licenseToken)

            if (editorSDK == null) {
                // Token you provided is not correct - empty or truncated
                Log.e(TAG, ERR_SDK_NOT_INITIALIZED_MESSAGE)
                result.error(ERR_SDK_NOT_INITIALIZED_CODE, ERR_SDK_NOT_INITIALIZED_MESSAGE, null)
            } else {
                if (videoEditorModule == null) {
                    // Initialize video editor sdk dependencies
                    videoEditorModule = VideoEditorModule().apply {
                        initialize(application)
                    }
                }
                result.success(null)
            }
        }
        ...
    }
}
```

:exclamation:  Important  
It is highly recommended to check the license state before using video editor.

Add message handler in [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L80) to check the license stat and start video editor.

```kotlin
val editorSDK = BanubaVideoEditor.initialize(licenseToken)
```

Instance of ```editorSDK``` is ```null``` if the license token is incorrect. In this
case you cannot use video editor and check your license token.

When Video Editor is initialized successfully Flutter sends [start channel message](../lib/main.dart#L80) to Android to start Video Editor SDK.
```dart
 Future<void> _startVideoEditorDefault() async {
  try {
    ...
    final result = await platform.invokeMethod(methodStartVideoEditor);
    ...
  } on PlatformException catch (e) {
    ...
  }
}
```
## Connect audio

These are optional sections in integration process. You will know how you can connect audio to Video Editor SDK.  
Please find more information in main [audio content](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content) guide.

### Connect Soundstripe
Specify ```SoundstripeProvider``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L113)

```kotlin
single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")){
   SoundstripeProvider()
}
```
and use ```false``` in [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29) to
play Soundstripe content in Video Editor.

### Connect Mubert
First, request API key from [Mubert](https://mubert.com/).  
:exclamation:  Banuba is not responsible for providing Mubert API key.

Specify ```MubertApiConfig``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L113)
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
and use ```false``` in [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29) to
play Mubert content in Video Editor.

### Connect External Audio API
Video Editor SDK allows to implement your experience of providing audio tracks using [External Audio API](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content#connect-external-api).  
To check out the simplest experience on Flutter you can set ```true``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29)  

:exclamation:  Important  
Video Editor SDK can play only audio tracks stored on the device.

## What is next?
This quickstart guide has just covered how to quickly integrate Android Video Editor SDK, 
it is considered you managed to start video editor from your Flutter project. 

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-ve/) to know more about the SDK and complete full integration.