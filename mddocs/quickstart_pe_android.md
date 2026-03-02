# Photo Editor Quickstart on Android

This guide walks you through integrating the Android Photo Editor SDK into your Flutter project. Integration and customization are performed in the `android` directory using native Android development practices.

- [Installation](#Installation)
- [Launch](#Launch)

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
    dependencies {
        def banubaPESdkVersion = '1.3.4'
        implementation "com.banuba.sdk:pe-sdk:${banubaPESdkVersion}"

        def banubaSdkVersion = '1.50.0'
        implementation "com.banuba.sdk:core-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:core-ui-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:ve-gallery-sdk:${banubaSdkVersion}"
        implementation "com.banuba.sdk:effect-player-adapter:${banubaSdkVersion}"
        }
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
From your [Flutter code](../lib/main.dart#64), use the same `MethodChannel` instance to invoke methods on the Android side.

```dart
await platformChannel.invokeMethod(methodInitPhotoEditor, LICENSE_TOKEN);
```

### Implement the Method on Android
In your `MainActivity.kt`, handle the [init method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#188) call and initialize the SDK with the received license token:

```diff
val licenseToken = call.arguments as String
+ photoEditorSDK = BanubaPhotoEditor.initialize(licenseToken)

if (photoEditorSDK == null) {
    // The SDK token is incorrect - empty or truncated
    ...
}
result.success(null)
```

### Start
From your [Flutter code](../lib/main.dart#L75) send message to Android for starting the Photo Editor SDK:
```dart
dynamic result = await platformChannel.invokeMethod(methodStartPhotoEditor);
```
and add corresponding [method](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L203) 
on Android side to start Photo Editor.

```kotlin
startActivityForResult(
    PhotoCreationActivity.startFromGallery(this),
    PHOTO_EDITOR_REQUEST_CODE
)
```

:exclamation: Important
1. Returns ```null```l if the license token is invalid – verify your token
2. [Check license activation](../android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt#L341) before starting the editor.

## Documentation
Explore the full capabilities of our [Photo Editor SDK](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-pe)