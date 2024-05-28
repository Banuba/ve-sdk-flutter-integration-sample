# Banuba Video and Photo Editor SDK - Flutter integration sample

## Overview
[Banuba Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to quickly add short video functionality and possibly AR filters and effects into your mobile app.  
[Banuba AR Photo Editor SDK](https://www.banuba.com/photo-editor-sdk) allows you to quickly add the photo editing capabilities to your app.  
The sample demonstrates how to integrate Video and Photo Editor SDK to [Flutter](https://flutter.dev/) project.

## Usage
### License
Before you commit to a license, you are free to test all the features of the SDK for free.  
The trial period lasts 14 days. To start it, [send us a message](https://www.banuba.com/video-editor-sdk#form).  
We will get back to you with the trial token.

Feel free to [contact us](https://www.banuba.com/support) if you have any questions.

## Launch

Set Banuba license token [within the app](lib/main.dart#L43)

### Android
1. Run ```flutter run``` in terminal to launch the sample app on a device or use IDE i.e. Intellij, VC, etc. to launch the app.
2. Follow [Video Editor](mddocs/quickstart_ve_android.md) and [Photo Editor](mddocs/quickstart_pe_android.md) quickstart guides to quickly integrate Video and Photo Editor SDK into your Flutter project on Android.

### iOS
1. Install CocoaPods dependencies. Open **ios** directory and run ```pod install``` in terminal.
2. Open **Signing & Capabilities** tab in Target settings and select your Development Team.
3. Run ```flutter run``` in terminal to launch the sample on a device or launch the app in IDE i.e. XCode, Intellij, VC, etc.
4. Follow [Video Editor](mddocs/quickstart_ve_ios.md) and [Photo Editor](mddocs/quickstart_pe_ios.md) quickstart guides to quickly integrate Video and Photo Editor SDK into your Flutter project on iOS.

## Dependencies
|       | Version | 
| --------- |:-------:| 
| Dart      |  3.3.0  | 
| Flutter   | 3.19.2  |
| Android      |  6.0+   |
| iOS          |  13.0+  |