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
  
  lazy var audioBrowserFlutterEngine = FlutterEngine(name: "audioBrowserEngine")
  
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
        if methodCall.method == "openVideoEditor" {
          videoEditor.openVideoEditor(
            fromViewController: controller
          )
          result("Success")
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Register audio browser engine
    audioBrowserFlutterEngine.run(withEntrypoint: "audioBrowser")
    GeneratedPluginRegistrant.register(with: audioBrowserFlutterEngine)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
