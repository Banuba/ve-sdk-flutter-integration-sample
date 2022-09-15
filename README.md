# Banuba AI Video Editor SDK - Flutter integration sample.

Banuba [AI Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to quickly add short video functionality and possibly AR filters and effects into your mobile app.
<br></br>
:exclamation: <ins>Support for Flutter plugin is under development at the moment and scheduled for __end Q4__. Please, reach out to [support team](https://www.banuba.com/faq/kb-tickets/new) to help you with your own Flutter integration.<ins>

<ins>Keep in mind that main part of integration and customization should be implemented in **android**, **ios** directories using Native Android and iOS development.<ins>

This sample demonstrates how to run VE SDK with [Flutter](https://flutter.dev/).


## Dependencies
|       |   Version | 
| --------- |:---------:| 
| Dart      | 2.17.6    | 
| Flutter   | 3.0.5     |

## Integration

### Token
We offer а free 14-days trial for you could thoroughly test and assess Video Editor SDK functionality in your app.

To get access to your trial, please, get in touch with us by [filling a form](https://www.banuba.com/video-editor-sdk) on our website. Our sales managers will send you the trial token.

:exclamation: __The token **IS REQUIRED** to run sample and an integration in your app.__</br>

### Prepare project
Run command ```flutter pub get``` to update dependencies.

### Android
1. Set Banuba token in the sample app [resources](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/res/values/string.xml#L5).
2. Run ```flutter run``` in terminal to launch the sample app on a device or launch the app in IDE i.e. Intellij, VC, etc.
3. Follow [Android Integration Guide](mddocs/android_integration.md) to integrate the SDK into your Flutter project.

### iOS
1. Install CocoaPods dependencies. Open **ios** directory and run ```pod install```.
2. Open Signing & Capabilities tab in Target settings and select your Development Team.
3. Set Banuba token in the sample app [BanubaVideoEditor initializer](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift#L13) .
4. Run command ```flutter run``` in terminal to launch the sample on a device or launch the app in IDE i.e. XCode, Intellij, VC, etc.
5. Follow [iOS Integration Guide](mddocs/ios_integration.md) to integrate the SDK into your Flutter project.