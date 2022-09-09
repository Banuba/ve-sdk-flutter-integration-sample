# Banuba AI Video Editor SDK - Flutter integration sample.

Banuba [AI Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to quickly add short video functionality and possibly AR filters and effects into your mobile app.
<br></br>
:exclamation: <ins>Support for Flutter plugin is under development at the moment and scheduled for __Q4__. Please, reach out to [support team](https://www.banuba.com/faq/kb-tickets/new) to help you with your own Flutter integration.<ins>

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

### Step 1 - Prepare project
Run command ```flutter pub get``` to update dependencies.

### Step 2 - Run sample Android app
1. Put Banuba token in [resources](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/res/values/string.xml#L5).
2. Run command ```flutter run``` in terminal to launch the sample app on a device or launch the app in IDE i.e. Intellij, VC, etc.
3. [Follow further instructions](https://github.com/Banuba/ve-sdk-android-integration-sample) to integrate VE SDK in your app using native Android development.

### Step 3 - Run sample iOS app
1. Install Cocoa Pods dependencies. Open **ios** directory and run ```pod init``` then ```pod install```.
1. Put Banuba token in [BanubaVideoEditor initializer](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift#L13) .
1. Run command ```flutter run``` in terminal to launch the sample on a device launch the app in IDE i.e. XCode, Intellij, VC, etc.
3. [Follow further instructions](https://github.com/Banuba/ve-sdk-ios-integration-sample) to integrate VE SDK in your app using native iOS development.