import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  private var useBanubaTokenStorage = true
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var videoEditor: VideoEditor
    
    // In case of using BanubaTokenStorageSDK and Firebase Database configure FirebaseApp
    if useBanubaTokenStorage {
      FirebaseApp.configure()
      videoEditor = VideoEditorModuleWithTokenStorage()
    } else {
      videoEditor = VideoEditorModule()
    }
    
    if let controller = window?.rootViewController as? FlutterViewController,
       let binaryMessenger = controller as? FlutterBinaryMessenger {
      
      let channel = FlutterMethodChannel(
        name: "startActivity/VideoEditorChannel",
        binaryMessenger: binaryMessenger
      )
      
      channel.setMethodCallHandler { methodCall, result in
        if methodCall.method == "openVideoEditor" {
          videoEditor.openVideoEditor(
            fromViewController: controller
          )
          result("Success")
        }
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
