# Banuba Video Editor SDK - Flutter integration sample.

## Overview
[Banuba Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to quickly add short video functionality and possibly AR filters and effects into your mobile app.  
The sample demonstrates how to integrate Video Editor SDK to [Flutter](https://flutter.dev/) project.

## Usage
### License
Before you commit to a license, you are free to test all the features of the SDK for free.  
The trial period lasts 14 days. To start it, [send us a message](https://www.banuba.com/video-editor-sdk#form).  
We will get back to you with the trial token.

Feel free to [contact us](https://www.banuba.com/faq/kb-tickets/new) if you have any questions.

### Installation
1. Run ```flutter pub get``` in terminal to load dependencies.
2. Set Banuba license token [within the app](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/lib/main.dart#L43).

### Run on Android
1. Run ```flutter run``` in terminal to launch the sample app on a device or launch the app in IDE i.e. Intellij, VC, etc.
2. Follow [Android Integration Guide](mddocs/android_integration.md) to integrate Video Editor SDK into your Flutter project.

### Run on iOS
1. Install CocoaPods dependencies. Open **ios** directory and run ```pod install``` in terminal.
2. Open **Signing & Capabilities** tab in Target settings and select your Development Team.
3. Run ```flutter run``` in terminal to launch the sample on a device or launch the app in IDE i.e. XCode, Intellij, VC, etc.
4. Follow [iOS Integration Guide](mddocs/ios_integration.md) to integrate Video Editor SDK into your Flutter project.

## Dependencies
|       |   Version | 
| --------- |:---------:| 
| Dart      | 2.17.6    | 
| Flutter   | 3.0.5     |
| Android      |  6.0+   |
| iOS          |  12.0+  |