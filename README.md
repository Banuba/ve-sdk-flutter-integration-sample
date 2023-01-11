# Banuba Video Editor SDK - Flutter integration sample.

[Banuba Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to quickly add short video functionality and possibly AR filters and effects into your mobile application.
<br></br>

<ins>Main part of integration and customization is implemented in **android**, **ios** directories using native Android and iOS development process.<ins>

This sample demonstrates how to integrate Video Editor SDK to [Flutter](https://flutter.dev/) project.


## Dependencies
|       |   Version | 
| --------- |:---------:| 
| Dart      | 2.17.6    | 
| Flutter   | 3.0.5     |
| Android      |  6.0+   |
| iOS          |  12.0+  |

## Usage

### Token
Before you commit to a license, you are free to test all the features of the SDK for free. The trial period lasts 14 days. To start it, [send us a message](https://www.banuba.com/video-editor-sdk#form).  
We will get back to you with the trial token.
You can store the token within the app.

Feel free to [contact us](https://www.banuba.com/faq/kb-tickets/new) if you have any questions.  


:exclamation: __The token **IS REQUIRED** to run sample and an integration in your app.__</br>

### Prepare project
Run ```flutter pub get``` in terminal to load dependencies.

### Android
1. Set Banuba license token [within the app](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/SampleApp.kt#L20).
2. Run ```flutter run``` in terminal to launch the sample app on a device or launch the app in IDE i.e. Intellij, VC, etc.
3. Follow [Android Integration Guide](mddocs/android_integration.md) to integrate Video Editor SDK into your Flutter project.

### iOS
1. Install CocoaPods dependencies. Open **ios** directory and run ```pod install``` in terminal.
2. Open **Signing & Capabilities** tab in Target settings and select your Development Team.
3. Set Banuba license token [within the app](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L15).
4. Run ```flutter run``` in terminal to launch the sample on a device or launch the app in IDE i.e. XCode, Intellij, VC, etc.
5. Follow [iOS Integration Guide](mddocs/ios_integration.md) to integrate Video Editor SDK into your Flutter project.