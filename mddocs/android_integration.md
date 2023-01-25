# Android integration guide into Flutter project

The following guide covers basic integration process into your Flutter project
where required part of an integration and customization of Banuba Video Editor SDK is implemented in **android** directory
of your Flutter project using native Android development process.

### Prerequisite
:exclamation: The license token **IS REQUIRED** to run sample and an integration into your app.  
Please follow [Installation](../README.md#Installation) guide if the license token is not set.

### Add SDK dependencies
Add Banuba repositories in [project gradle](../android/build.gradle#L55) file to get Video Editor SDK and AR Cloud dependencies.

```groovy
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/Banuba/banuba-ve-sdk")
            credentials {
                username = "Banuba"
                password = ""
            }
        }
        maven {
            name = "ARCloudPackages"
            url = uri("https://github.com/Banuba/banuba-ar")
            credentials {
                username = "Banuba"
                password = ""
            }
        }
```

Add Video Editor SDK dependencies in [app gradle](../android/app/build.gradle#L313) file.
```groovy
    def banubaSdkVersion = '1.26.3'
    implementation "com.banuba.sdk:ffmpeg:4.4"
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
### Add SDK integration helper
Add [VideoEditorIntegrationHelper.kt](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorIntegrationHelper.kt) file
to initialize SDK dependencies. This class also allows you to customize many Video Editor SDK features i.e. min/max video durations, export flow, order of effects and others.

### Update AndroidManifest
Add ```VideoCreationActivity``` in your [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L53) file.
The Activity is used to bring together a number of screens in a certain flow.

Next, allow Network by adding permissions
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```
and ```android:usesCleartextTraffic="true"``` in [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml).

Network traffic is used for downloading AR effects from AR Cloud and stickers from [Giphy](https://giphy.com/).

Please set up correctly [network security config](https://developer.android.com/training/articles/security-config) and use of ```android:usesCleartextTraffic```
by following [guide](https://developer.android.com/guide/topics/manifest/application-element).

### Add resources
Video Editor SDK uses a lot of resources required for running.  
Please make sure all these resources are provided in your project.

1. [bnb-resources](../android/app/src/main/assets/bnb-resources) to use build-in Banuba AR and Lut effects. Using Banuba AR ```assets/bnb-resources/effects``` requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.  
   
2. [color](../android/app/src/main/res/color),
[drawable](../android/app/src/main/res/drawable),
[drawable-hdpi](../android/app/src/main/res/drawable-hdpi),
[drawable-ldpi](../android/app/src/main/res/drawable-ldpi),
[drawable-mdpi](../android/app/src/main/res/drawable-mdpi),
[drawable-xhdpi](../android/app/src/main/res/drawable-xhdpi),
[drawable-xxhdpi](../android/app/src/main/res/drawable-xxhdpi),
[drawable-xxxhdpi](../android/app/src/main/res/drawable-xxxhdpi) are visual assets used in views and added in the sample for simplicity. You can use your specific assets.  
   
3. [values](../android/app/src/main/res/values) to use colors and themes. Theme ```VideoCreationTheme``` and its styles use resources in **drawable** and **color** directories.  

### Configure media export
Video Editor SDK allows to export a number of media files to meet your requirements.
Implement ```ExportParamsProvider``` and provide ```List<ExportParams>``` where every ```ExportParams``` is a media file i.e. video or audio -
[See example](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorIntegrationHelper.kt#L175).

Use ```ExportParams.Builder.fileName()``` method to provide custom media file name.

### Add platform channel
[Platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) is used for communication between Flutter and Android.

Add channel message handler to your [FlutterActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L48) 
to listen to calls from Flutter side. Flutter sends messages in this channel to initialize or start Video Editor.
```kotlin
    val appFlutterEngine = requireNotNull(flutterEngine)
    GeneratedPluginRegistrant.registerWith(appFlutterEngine)

    MethodChannel(
    appFlutterEngine.dartExecutor.binaryMessenger,
    "CHANNEL"
    ).setMethodCallHandler { call, result ->
    // Handle method calls
    }
```

### Start SDK
First, initialize Video Editor SDK using license token in [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L75)` on Android.
```kotlin
val videoEditor = BanubaVideoEditor.initialize(LICENSE_TOKEN)
```
Please note, instance ```videoEditor``` can be **null** if the license token is incorrect.  

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

Since Video Editor SDK is launched within ```VideoCreationActivity``` exported video is returned from the Activity
into [onActivityResult](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#207).

Export returns [result](../lib/main.dart#L79)  where you can pass required data i.e. exported video stored to Flutter.

### Enable custom Audio Browser experience
Video Editor SDK allows to implement your experience of providing audio tracks for your users - custom Audio Browser.  
To check out the simplest experience on Flutter you can set ```true``` to [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29)  
:exclamation:Video Editor SDK can play only files stored on device.

### Connect Mubert 
:exclamation: Please request API key from [Mubert](https://mubert.com/). Banuba is not responsible for providing Mubert API key.  
Set Mubert API [within the app](../android/app/src/main/res/values/string.xml#L4) and
[CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L29)  to ```false```
for playing Mubert content in Video Editor Audio Browser.  

## What is next?
We have covered a basic process of Banuba Video Editor SDK integration into your Flutter project. 
More integration details and customization options you will find in [Banuba Video Editor SDK Android Integration Sample](https://github.com/Banuba/ve-sdk-android-integration-sample).