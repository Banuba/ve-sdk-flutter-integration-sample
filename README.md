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

## Launch

Set your Banuba license token [in the application](lib/main.dart#L43)

### Android
1. Run the app
```bash
flutter run
```
2. Integration guides:
   - [Video Editor](mddocs/quickstart_ve_android.md) 
   - [Photo Editor](mddocs/quickstart_pe_android.md)

### iOS
1. Install CocoaPods dependencies
```bash
cd ios
pod install
```
2. Configure signing 
   - Open ios/Runner.xcworkspace in Xcode
   - Select the Runner target
   - Choose your Development Team in Signing & Capabilities
3. Run the app
```bash
flutter run
```
4. Integration guides 
   - [Video Editor](mddocs/quickstart_ve_ios.md) 
   - [Photo Editor](mddocs/quickstart_pe_ios.md)

## Documentation
Explore the full capabilities of our SDKs:
- [Video Editor SDK](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-ve)
- [Photo Editor SDK](https://docs.banuba.com/ve-pe-sdk/docs/android/requirements-pe)

## Support
For questions about Video Editor or Photo Editor SDK, reach out to Banuba support service
- [Video Editor SDK](https://www.banuba.com/faq/kb-tickets/new)
- [Photo Editor SDK](https://www.banuba.com/support)

## Dependencies
|       | Version | 
| --------- |:-------:| 
| Dart      |  3.3.0  | 
| Flutter   | 3.19.2  |
| Android      |  8.0+   |
| iOS          |  15.0+  |