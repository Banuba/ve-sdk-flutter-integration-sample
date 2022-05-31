# Banuba AI Video Editor SDK. Integration sample for Flutter.
Banuba [Video Editor SDK](https://www.banuba.com/video-editor-sdk) allows you to add a fully-functional video editor with Tiktok-like features, AR filters and effects in your app.   
The following sample brifly demonstrates how you can integrate our SDK into your [Flutter](https://flutter.dev/) project.  

# Android  
1. Put [Banuba token](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/res/values/string.xml#L5) in resources.
1. Run command **flutter run** to launch the sample on device or **cd android && ./gradlew clean && cd .. && flutter run** to clean and re-run the sample.

# iOS  
1. Install cocoapods dependencies using commands **pod init**(if needed) and **pod install** in the ios folder.
1. Put [Banuba Face AR token](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift#L13) in BanubaVideoEditor initializer.
1. Run command **flutter run** to launch the sample on device.

# Want to know more about the SDK?  
Please visit our main repositories with native [Android](https://github.com/Banuba/ve-sdk-android-integration-sample) and [iOS](https://github.com/Banuba/ve-sdk-ios-integration-sample) integrations to get full information about the SDK.
