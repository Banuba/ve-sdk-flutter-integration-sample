import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  /*
   true - to enable Banuba token storage and load token from Firebase in this sample..
   false - to use token stored locally.
   */
  private var useBanubaTokenStorage = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var videoEditor: VideoEditor
    
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
        if methodCall.method == "StartBanubaVideoEditor" {
          videoEditor.openVideoEditorDefault(
            fromViewController: controller
          )
          result("Success")
        } else if methodCall.method == "StartBanubaVideoEditorPIP" {
            let videoFilePath = methodCall.arguments as? String
            if (videoFilePath == nil) {
                result("Failed! Invalid video file path")
                return
            }
            
            let videoURL = URL.init(fileURLWithPath: videoFilePath!)
            
            videoEditor.openVideoEditorPIP(
              fromViewController: controller,
              videoURL: videoURL
            )
            
            result("Success")
            
        }
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
