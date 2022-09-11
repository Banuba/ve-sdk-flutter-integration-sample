# Android Integration Guide into Flutter project

An integration and customization of Banuba VE UI SDK is implemented in **android** directory 
of your Flutter project using native Android development process.

## Basic
The following steps help to complete basic integration into your project

<ins>All changes are made in **android** directory.</ins>
1. __Move SDK Initializer class__ </br>
     Move [BanubaVideoEditorUISDK.kt](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/BanubaVideoEditorUISDK.kt) file.</br>
     This class helps to initialize and customize VE UI SDK.</br><br>

2. __Initialize the SDK in your application__ </br>
     Use ```BanubaVideoEditorUISDK().initialize(...)``` in your ```Application.onCreate()``` method to initialize the SDK.</br>
     [See full example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/SampleApp.kt#L10)</br><br>

3. __Update AndroidManifest.xml__ </br>
     Add ```VideoCreationActivity``` in your AndroidManifest.xml file. The Activity is used to bring together a number of screens in a certain flow.</br>
     [See full example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/AndroidManifest.xml#L47)</br><br>

4. __Move assets and resources__</br>
      1. [bnb-resources](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/assets/bnb-resources) to use hardcoded Banuba AR and Lut effects.
      Using Banuba AR ```assets/bnb-resources/effects``` requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.<br></br>
   
      2. [color](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/color),
      [drawable](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable),
      [drawable-hdpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-hdpi),
      [drawable-ldpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-ldpi),
      [drawable-mdpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-mdpi),
      [drawable-xhdpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-xhdpi),
      [drawable-xxhdpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-xxhdpi),
      [drawable-xxxhdpi](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/drawable-xxxhdpi) are visual assets used in views and added in the sample for simplicity. You can use your specific assets.<br></br>
   
      3. [values](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/android/app/src/main/res/values) to use colors and themes. Theme ```VideoCreationTheme``` and its styles use resources in **drawable** and **color** directories.<br></br>

5. __Start the SDK__ </br>
    Use ```VideoCreationActivity.startFromCamera(...)``` method to start VE UI SDK from Camera screen.
    Once the SDK starts you can observe export video results.</br>
    [See full example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/android/app/src/main/kotlin/com/banuba/flutter/flutter_ve_sdk/MainActivity.kt)</br><br>



## What is next?

We have covered a basic process of integration VE UI SDK into your project. 
More integration details and customizations you can find in our main [VE UI SDK Integration Sample](https://github.com/Banuba/ve-sdk-android-integration-sample).