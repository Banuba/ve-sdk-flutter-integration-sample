# Android Photo Editor SDK quickstart

This guide demonstrates how to quickly integrate Android Photo Editor SDK into your Flutter project.
The main part of an integration and customization is implemented in ```android``` directory
in your Flutter project using native Android development process.

Once complete you will be able to launch photo editor in your Flutter project.

- [Installation](#Installation)
- [Launch](#Launch)
- [What is next?](#What-is-next)

## Installation
GitHub Packages is used for downloading Android Photo Editor SDK modules.
First, add repositories to [gradle](../android/build.gradle#L1) file in ```allprojects``` section.

```groovy
allprojects {
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/Banuba/banuba-ve-sdk")
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
    }
}
```

Specify Photo Editor SDK dependencies in the app gradle file.
```groovy
    dependencies {
        def banubaPESdkVersion = '1.2.14'
        implementation "com.banuba.sdk:pe-sdk:${banubaPESdkVersion}"

        def banubaSdkVersion = '1.45.1'
        implementation "com.banuba.sdk:core-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:core-ui-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:ve-gallery-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:effect-player-adapter:${banubaSdkVersion}"
        }
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

Send [initPhotoEditor](../lib/main.dart#64) message from Flutter to Android for initializing Photo Editor SDK:

```dart
await platformChannel.invokeMethod(methodInitPhotoEditor, LICENSE_TOKEN);
```

Add [init method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#188) on Android side to initialize Photo Editor SDK:

```diff
val licenseToken = call.arguments as String
+ photoEditorSDK = BanubaPhotoEditor.initialize(licenseToken)

if (photoEditorSDK == null) {
    // The SDK token is incorrect - empty or truncated
    ...
}
result.success(null)
```

Send [startPhotoEditor](../lib/main.dart#L75) message from Flutter to Android for starting the Photo Editor SDK:
```dart
dynamic result = await platformChannel.invokeMethod(methodStartPhotoEditor);
```
and add corresponding [method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L203) on Android side to start Photo Editor.

```kotlin
startActivityForResult(
    PhotoCreationActivity.startFromGallery(this),
    PHOTO_EDITOR_REQUEST_CODE
)
```

> [!IMPORTANT]  
> 1. Instance ```photoEditorSDK``` is ```null``` if the license token is incorrect. In this case you cannot use photo editor. Check your license token.
> 2. It is highly recommended to [check](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L192) if the license is active before starting Photo Editor.

## What is next?

This quickstart guide has just covered how to quickly integrate Android Photo Editor SDK,
it is considered you managed to start photo editor from your Flutter project.

Please check out [docs](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-pe/) to know more about the SDK and complete full integration.