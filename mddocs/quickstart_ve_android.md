# Android Video Editor SDK quickstart

This guide walks you through integrating the Android Video Editor SDK into your Flutter project. Integration and customization are performed in the `android` directory using native Android development practices.

- [Installation](#Installation)
- [Resources](#Resources)
- [AndroidManifest Updates](#AndroidManifest-Updates)
- [Koin Module Setup](#Koin-Module-Setup)
- [Launch](#Launch)
- [Editor V2](#Editor-v2)
- [Face AR Effects](#Face-AR-Effects)
- [Connect audio](#Connect-audio)
- [Documentation](#Documentation)

## Installation
Add the Banuba repository to your project using **either** Groovy **or** Kotlin DSL:

**Groovy** (in project's [build.gradle](../android/build.gradle#L1))

```groovy
...

allprojects {
    repositories {
       ...
       maven {
          name = "nexus"
          url = uri("https://nexus.banuba.net/repository/maven-releases")
       }
    }
}
```
or

**Kotlin** (settings.gradle.kts)
```kotlin
...
dependencyResolutionManagement {
   repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
   repositories {
      ...
      maven {
         name = "nexus"
         url = uri("https://nexus.banuba.net/repository/maven-releases")
      }
   }
}
```

Add dependencies to your app's [gradle](../android/build.gradle#L83)
```groovy
    def banubaSdkVersion = '1.50.0'
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

Ensure these plugins are in your app's [gradle](../android/build.gradle#L1).
```groovy
   plugins {
        id "com.android.application"
        id "kotlin-android"
        id "dev.flutter.flutter-gradle-plugin"
        id "kotlin-parcelize"
}
```

## AndroidManifest Updates

Add the following to your [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L53):

1. ```VideoCreationActivity``` – orchestrates the video editor screens
``` xml
<activity android:name="com.banuba.sdk.ve.flow.VideoCreationActivity"
    android:screenOrientation="portrait"
    android:theme="@style/CustomIntegrationAppTheme"
    android:windowSoftInputMode="adjustResize"
    tools:replace="android:theme" />
```  

**Important**  
Add [CustomIntegrationAppTheme](../android/app/src/main/res/values/styles.xml#L28) styles resource file.

2. **Network permissions** (optional)– only required if using [Giphy](https://giphy.com/) stickers or downloading AR effects from the cloud.
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

**Note:** You'll also need a custom VideoCreationTheme [example](../android/app/src/main/res/values/styles.xml#L28) to style the editor UI.

Please set up correctly [network security config](https://developer.android.com/training/articles/security-config) and use of ```android:usesCleartextTraffic```
by following [guide](https://developer.android.com/guide/topics/manifest/application-element).  

## Koin Module Setup

1. Create [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt) to initialize and customize the Video Editor SDK.
2. Inside it, add [SampleIntegrationVeKoinModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L60) with your customizations:

``` diff
class VideoEditorModule {
   
   fun initialize(application: Application) {
        startKoin {
            androidContext(application)
            allowOverride(true)

            // IMPORTANT! order of modules is required
            modules(
                VeSdkKoinModule().module,
                VeExportKoinModule().module,
                VePlaybackSdkKoinModule().module,

                // Use AudioBrowserKoinModule ONLY if your contract includes this feature.
                AudioBrowserKoinModule().module,

                // IMPORTANT! ArCloudKoinModule should be set before TokenStorageKoinModule to get effects from the cloud
                ArCloudKoinModule().module,

                VeUiSdkKoinModule().module,
                VeFlowKoinModule().module,
                BanubaEffectPlayerKoinModule().module,
                GalleryKoinModule().module,

                // Sample integration module
+                SampleIntegrationVeKoinModule().module,
            )
        }
    }
   
 +  private class SampleIntegrationVeKoinModule {

    val module = module {
        single<ArEffectsRepositoryProvider>(createdAtStart = true) {
            ArEffectsRepositoryProvider(
                arEffectsRepository = get(named("backendArEffectsRepository"))
            )
        }


        // Audio Browser provider implementation.
        single<ContentFeatureProvider<TrackData, Fragment>>(
            named("musicTrackProvider")
        ) {
            if (MainActivity.CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER) {
                AudioBrowserContentProvider()
            } else {
                // Default implementation that supports Local audio stored on the device
                AudioBrowserMusicProvider()
            }
        }
    }
}
}
```

### Export 

The Video Editor SDK exports a single video with auto quality by default. Auto quality is based on device hardware capabilities.

Every exported media is passed to the [onActivityResult](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#236) method in MainActivity.kt. 
Process the result there and forward it to the [handler](../lib/main.dart#L189) on the Flutter side.

## Launch
The integration uses [Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels) for communication between Flutter and the native Android layer.

### Add the Channel Handler
In your [MainActivity](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L71) set up a `MethodChannel` and attach a handler to listen for calls from Flutter.
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

### Send Message from Flutter
From your [Flutter code](../lib/main.dart#90), use the same `MethodChannel` instance to invoke methods on the Android side.

```dart
await platformChannel.invokeMethod('initVideoEditor', LICENSE_TOKEN);
```

### Implement the Method on Android
In your `MainActivity.kt`, handle the [init method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#87) call and initialize the SDK with the received license token:

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
:exclamation: Important
1. Returns ```null```l if the license token is invalid – verify your token
2. [Check license activation](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L341) before starting the editor.
3. Expired/revoked licenses show a "Video content unavailable" screen


### Start
From your [Flutter code](../lib/main.dart#L97) send message to Android for starting the Video Editor SDK:
```dart
final result = await platformChannel.invokeMethod('startVideoEditor');
```
and add corresponding [method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L103)
on Android side to start Video Editor.

```kotlin
  startActivityForResult(
   VideoCreationActivity.startFromCamera(
      context = this,
      // setup data that will be acceptable during export flow
      additionalExportData = null,
      // set TrackData object if you open VideoCreationActivity with preselected music track
      audioTrackData = null,
      // set PiP video configuration
      pictureInPictureConfig = PipConfig(
         video = Uri.EMPTY,
         openPipSettings = false
      ),
      extras = extras
   ), VIDEO_EDITOR_REQUEST_CODE
)
```

## Editor V2

To keep up with the latest developments and best practices, our team has completely redesigned the Video Editor SDK to be as convenient and enjoyable as possible.

Create a ```Bundle``` with the Editor V2 UI configuration and pass it as [extras](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#68) to any [Video Editor start method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#277).

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

This section describes how to connect custom audio tracks to the Video Editor SDK. This is an optional step in the integration process.

### Connect External Audio API

Video Editor SDK allows to implement your experience of providing your audio tracks using [External Audio API](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content#connect-external-api).

For a quick demonstration of this flow on Flutter, you can enable the pre-configured custom audio browser 
by setting [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34) to ```true``` in ```MainActivity.kt```.

> [!IMPORTANT]  
> The Video Editor SDK can only play audio tracks that are stored locally on the device. You are responsible for downloading or providing the audio file to the correct local path before applying it.

For complete implementation details, including how to build a custom UI and handle audio selection callbacks, refer to the dedicated [Audio Content](https://docs.banuba.com/ve-pe-sdk/docs/android/guide_audio_content) guide.

### Connect Banuba Music
To use audio tracks from Banuba Music in the Video Editor:

1. Set [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34) to ```false``` in MainActivity.kt
2. Specify ```BanubaMusicProvider``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L72):

> [!IMPORTANT]
> This feature is not activated by default. Contact Banuba representatives for access.

```kotlin
single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")){
   BanubaMusicProvider()
}
```

### Connect Soundstripe
To use audio tracks from [Soundstripe](https://www.soundstripe.com/) in the Video Editor:

1. Set [CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L34) to ```false``` in MainActivity.kt

2. Specify ```SoundstripeProvider``` in your [VideoEditorModule](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/VideoEditorModule.kt#L72):

> [!IMPORTANT]
> This feature is not activated by default. Contact Banuba representatives for access.

```kotlin
single<ContentFeatureProvider<TrackData, Fragment>>(named("musicTrackProvider")){
   SoundstripeProvider()
}
```

## Documentation
Explore the full capabilities of our [Video Editor SDK](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-ve)