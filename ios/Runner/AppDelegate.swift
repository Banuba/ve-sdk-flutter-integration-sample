import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController,
       let binaryMessenger = controller as? FlutterBinaryMessenger {

      let videoEditor = VideoEditorModule()
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
