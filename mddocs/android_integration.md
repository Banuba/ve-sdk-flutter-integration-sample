# Android Video Editor SDK quickstart

- [Overview](#Overview)
- [Prerequisites](#Prerequisites)
- [Add dependencies](#Add-dependencies)
- [Add module class](#Add-module-class)
- [Update AndroidManifest](#Update-AndroidManifest)
- [Add resources](#Add-resources)
- [Implement export](#Implement-export)
- [Add platform channel](#Add-platform-channel)
- [Init and start](#Init-and-start)
- [Enable custom Audio Browser experience](#Enable-custom-Audio-Browser-experience)
- [Connect Mubert](#Connect-Mubert)
- [Complete full integration](#Complete-full-integration)

## Overview
The following quickstart guide explains how to quickly integrate Android Video Editor SDK into your Flutter project.
The main part of an integration and customization is implemented in ```android``` directory
of your Flutter project using native Android development process. 

You will be able to launch video editor from your Flutter project when you complete all these integration steps.

## Prerequisites
Complete [Installation](../README.md#Installation) guide to proceed.

## Add dependencies
Add Banuba repositories to [project gradle](../android/build.gradle#L15) file in ```allprojects``` section to get SDK dependencies.

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

        ...
    }
}
```

Add Video Editor SDK dependencies in [app gradle](../android/app/build.gradle#L77) file.
```groovy
    def banubaSdkVersion = '1.31.0'
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
    implementation "com.banuba.sdk:banuba-token-storage-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-export-sdk:${banubaSdkVersion}"
    implementation "com.banuba.sdk:ve-playback-sdk:${banubaSdkVersion}"
```
## Add module class
Add [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt) file 
to your project. You can use this class to initialize and customize Video Editor SDK features.

## Update AndroidManifest
Add ```VideoCreationActivity``` in your [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L53).
This Activity joins a number of screens into video editor flow.  
:exclamation:  Important  
It is possible to skip some screens, it is not possible to change the order.

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

Network traffic is used for downloading AR effects from AR Cloud and stickers from [Giphy](https://giphy.com/).

Please set up correctly [network security config](https://developer.android.com/training/articles/security-config) and use of ```android:usesCleartextTraffic```
by following [guide](https://developer.android.com/guide/topics/manifest/application-element).

## Add resources
Video Editor SDK consumes a lot of visual resources. Most part of the resources is delivered in the SDK. 
Some resources depend on your project requirements and should be copied and pasted manually.

### Banuba resources
[bnb-resources](../android/app/src/main/assets/bnb-resources)  Banuba AR and color filters. Use of AR effects ```assets/bnb-resources/effects``` requires [Face AR](https://docs.banuba.com/face-ar-sdk-v1) product.  

### Android resources
- [drawable-hdpi](../android/app/src/main/res/drawable-hdpi),
- [drawable-xhdpi](../android/app/src/main/res/drawable-xhdpi),
- [drawable-xxhdpi](../android/app/src/main/res/drawable-xxhdpi),
- [drawable-xxxhdpi](../android/app/src/main/res/drawable-xxxhdpi) are visual assets for color filter previews.  
- [styles.xml](../android/app/src/main/res/values/styles.xml) includes implementation of ```VideoCreationTheme``` of Video Editor SDK.  

:bulb:  Hint
If you want to replace default resources i.e. icons you should add your custom 
resources in folders described above [Android resources](#Android-resources), try to keep icon names or override use of in Android themes.

## Implement export
Video Editor SDK supports export multiple media files to meet your product requirements.
Create class [CustomExportParamsProvider](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L158) 
and implement ```ExportParamsProvider``` to provide ```List<ExportParams>``` where every ```ExportParams``` is a media file i.e. video or audio.

Use ```ExportParams.Builder.fileName``` method to set custom media file name.

## Add platform channel
[Platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) is used for communication between Flutter and Android.

Add channel message handler to your [FlutterActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L48) 
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

## Init and start
### Init sdk
Flutter should send [init channel message](../lib/main.dart#L78) to Android to initialize Video Editor SDK using ```platform.invokeMethod```.
```dart
 Future<void> _initVideoEditor() async {
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
+            videoEditorSDK = BanubaVideoEditor.initialize(licenseToken)

            if (videoEditorSDK == null) {
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
Instance of ```videoEditorSDK``` can be ```null``` if the license token is incorrect. In this 
case you cannot use video editor and check your license token.

### Start sdk
:exclamation:  Important  
It is highly recommended to check the license state before using video editor.

When Video Editor is initialized successfully Flutter should send [start channel message](../lib/main.dart#L80) to Android.
```dart
 Future<void> _startVideoEditorDefault() async {
  try {
    await _initVideoEditor();

    final result = await platform.invokeMethod(methodStartVideoEditor);

    _handleExportResult(result);
  } on PlatformException catch (e) {
    _handlePlatformException(e);
  }
}
```

Add message handler in [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L93) 
to check the license stat and start video editor.

```kotlin
val videoEditor = BanubaVideoEditor.initialize(licenseToken)
```
Instance of ```videoEditor``` is ```null``` if the license token is incorrect.

### Export result
Handle export result in [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#207) and 
pass the result to [Flutter](../lib/main.dart#L80).

## Enable custom Audio Browser experience
Video Editor SDK allows to implement your experience of providing audio tracks - custom Audio Browser.  
To check out the simplest experience on Flutter you can set ```true``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29)  

:exclamation:  Important  
Video Editor SDK can play only audio tracks stored on the device.

## Connect Mubert 
First, request API key from [Mubert](https://mubert.com/).  
:exclamation:  Banuba is not responsible for providing Mubert API key.  

Set Mubert API in [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt) 
```kotlin
single {
    MubertApiConfig("API KEY")
}
```
and use ```false``` in [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29) to 
play Mubert content in Video Editor Audio Browser.

## Complete full integration
This quickstart guide has just covered how to quickly integrate Android Video Editor SDK, 
it is considered you managed to start video editor from your Flutter project.  

We highly recommend to take advantage of all features and complete full integration of video editor
in your project by learning [Main Android quickstart guide](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/quickstart.md).  

:bulb: Recommendations  
- [Export guide](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/guide_export.md)
- [Advanced integration guide](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/advanced_integration.md)
- [Face AR and AR Cloud guide](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/guide_far_arcloud.md)
- [Audio guide](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/guide_audio_content.md)
- [Launch methods](https://github.com/Banuba/ve-sdk-android-integration-sample/blob/main/mddocs/advanced_integration.md#Launch-methods)