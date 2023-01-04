# iOS Integration Guide into Flutter project

An integration and customization of Banuba Video Editor SDK is implemented in **ios** directory
of your Flutter project using native iOS development process.

## Basic
The following steps help to complete basic integration into your Flutter project.

<ins>All changes are made in **ios** directory.</ins>
1. __Set Banuba Video Editor SDK token__  
   Set Banuba token in the sample app [AppDelegate](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L23).<br></br>
   To get access to your trial, please, get in touch with us by [filling a form](https://www.banuba.com/video-editor-sdk) on our website. Our sales managers will send you the trial token.<br>
   :exclamation: The token **IS REQUIRED** to run sample and an integration in your app.  
   Check this [guide](#Obtain-Banuba-Video-Editor-SDK-token-from-a-server) to store and obtain a token from a server.<br></br>

2. __Add Banuba Video Editor SDK dependencies__  
   Add iOS Video Editor SDK dependencies to your Podfile.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Podfile)</br><br>

3. __Add SDK Initializer class__  
   Add [VideoEditorModule.swift](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModule.swift) file to your project.
   This class helps to initialize and customize Video Editor SDK.</br><br>

4. __Setup platform channel to start Video Editor SDK__  
   Create ```FlutterMethodChannel``` in your ```AppDelegate``` instance to start ```VideoEditorModule```.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#58)</br>
   Find more information about platform channels in [Flutter developer documentation](https://docs.flutter.dev/development/platform-integration/platform-channels).</br><br>

5. __Add assets and resources__  
   1. [bundleEffects](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/bundleEffects) to use build-in Banuba AR effects. Using Banuba AR requires [Face AR product](https://docs.banuba.com/face-ar-sdk-v1). Please contact Banuba Sales managers to get more AR effects.
   2. [luts](https://github.com/Banuba/ve-sdk-flutter-integration-sample/tree/main/ios/luts) to use Lut effects shown in the Effects tab.</br><br>

6. __Start Video Editor SDK__  
   Use ```platform.invokeMethod``` to start Video Editor SDK from Flutter.</br>
    ```dart
       Future<void> _startVideoEditorDefault() async {
          try {
            final result = await platform.invokeMethod('StartBanubaVideoEditor');
            ...
          } on PlatformException catch (e) {
            debugPrint("Error: '${e.message}'.");
         }
      }
   ```
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/lib/main.dart#L58)</br>
7. __Connect Mubert to Video Editor Audio Browser__ </br>
   :exclamation: Please request API key from Mubert. <ins>Banuba is not responsible for providing Mubert API key.</ins><br></br>
   Set Mubert API key in [AudioBrowser initializer](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L139) to play [Mubert](https://mubert.com/) content in Video Editor Audio Browser.<br></br>

8. __Custom Audio Browser experince__ </br>
    Video Editor SDK allows to implement your experience of providing audio tracks for your users - custom Audio Browser.  
    To check out the simplest experience on Flutter you can set ```true``` to [useCustomAudioBrowser](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L20)

## Obtain Banuba Video Editor SDK token from a server  

Banuba Video Editor SDK provides functionality to use a token loaded from a server. It is achieved by implementing ```TokenProvidable```. 
Video Editor SDK can be initialized once the token is loaded.  

SDK has built-in support of [Firebase Realtime Database](https://firebase.google.com/docs/database) for 
storing and loading the token.  

Next, you will see how to use Firebase Realtime Database and start Banuba Video Editor SDK with loaded token.
1. __Firebase setup__  
   Please complete [Add Firebase to your project](https://firebase.google.com/docs/ios/setup) and [Setup Firebase Realtime Database](https://firebase.google.com/docs/database/ios/start) steps.  
   Import ```GoogleService-Info.plist``` file into your project. [Read more](https://firebase.google.com/docs/ios/setup#add-config-file).  
   Create new database and snapshot for storing token. As a result you will have a pair - database url(```targetURL``` i.e. *"https://...-default-rtdb.europe-west1.firebasedatabase.app/"*) and snapshot name(```tokenSnapshot``` i.e. *"banubaToken"*). These values will be used a bit later.<br></br>
2. __Add dependency__  
   Add ```BanubaTokenStorageSDK``` pod dependency in your [Podfile](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Podfile)<br></br>
3. __Add fallback token__  
   Add file ```BanubaVideoEditorSDK-Info.plist``` into your project and set Banuba Video Editor SDK token. 
   This token is used in case when it is not possible to obtain the token from the server.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/BanubaVideoEditorSDK-Info.plist)<br></br>
4. __Set Firebase Database params__   
   Set ```targetURL``` and ```tokenSnapshot``` of your Firebase Database in ```FirebaseTokenProvider``` class.</br>
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModuleWithTokenStorage.swift#L17)<br></br>
5. __Usage__  
   Set ```true``` to ```useBanubaTokenStorage``` in [AppDelegate](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/AppDelegate.swift#L26) to enable Token Storage. 
   Use fetched token to initialize and start Video Editor SDK.  
   [See example](https://github.com/Banuba/ve-sdk-flutter-integration-sample/blob/main/ios/Runner/VideoEditorModuleWithTokenStorage.swift#L34)<br></br>

Check [API for using token from Firebase in the SDK](https://github.com/Banuba/ve-sdk-ios-integration-sample/blob/Add_description_using_banuba_token_storage_sdk/mdDocs/token_on_firebase.md) to get more information about integration.


## What is next?

We have covered a basic process of Banuba Video Editor SDK integration into your Flutter project.</br>
More details and customization options you will find in [Banuba Video Editor SDK iOS Integration Sample](https://github.com/Banuba/ve-sdk-ios-integration-sample).