import UIKit
import Flutter
import Firebase
import AVKit
import BanubaAudioBrowserSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    /*
     true - to enable Banuba token storage and load token from Firebase in this sample..
     false - to use token stored locally.
     */
    private let useBanubaTokenStorage = false
    
    /*
     true - uses custom audio browser implementation in this sample.
     false - to keep default implementation.
     */
    private let useCustomAudioBrowser = false
  
    // License token is required to start Video Editor SDK
    static let licenseToken: String = <#Enter your license token#>
    
    lazy var audioBrowserFlutterEngine = FlutterEngine(name: "audioBrowserEngine")
    
    static let channelName = "startActivity/VideoEditorChannel"
    
    static let methodStartVideoEditor = "StartBanubaVideoEditor"
    static let methodStartVideoEditorPIP = "StartBanubaVideoEditorPIP"
    static let methodDemoPlayExportedVideo = "PlayExportedVideo"
    
    static let errMissingExportResult = "ERR_MISSING_EXPORT_RESULT"
    static let errStartPIPMissingVideo = "ERR_START_PIP_MISSING_VIDEO"
    static let errExportPlayMissingVideo = "ERR_EXPORT_PLAY_MISSING_VIDEO"
    
    static let argExportedVideoFile = "exportedVideoFilePath"
    
    
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
                name: AppDelegate.channelName,
                binaryMessenger: binaryMessenger
            )
            
            channel.setMethodCallHandler { methodCall, result in
                let call = methodCall.method
                
                if call == AppDelegate.methodStartVideoEditor {
                    videoEditor.openVideoEditorDefault(
                        fromViewController: controller,
                        flutterResult: result
                    )
                } else if call == AppDelegate.methodStartVideoEditorPIP {
                    let pipVideoFilePath = methodCall.arguments as? String
                    
                    if let videoFilePath = pipVideoFilePath {
                        videoEditor.openVideoEditorPIP(
                            fromViewController: controller,
                            videoURL: URL.init(fileURLWithPath: videoFilePath),
                            flutterResult: result
                        )
                    } else {
                        print("Missing or invalid video file path = \(pipVideoFilePath) to start video editor in PIP mode.")
                        result(FlutterError(code: AppDelegate.errStartPIPMissingVideo,
                                            message: "Missing video to start video editor in PIP mode",
                                            details: nil))
                    }
                } else if call == AppDelegate.methodDemoPlayExportedVideo {
                    /*
                     NOT REQUIRED FOR INTEGRATION
                     Added for playing exported video file.
                     */
                    let demoPlayVideoFilePath = methodCall.arguments as? String
                    
                    if let videoFilePath = demoPlayVideoFilePath {
                        self.demoPlayExportedVideo(controller: controller, videoURL: URL.init(fileURLWithPath: videoFilePath))
                    } else {
                        print("Missing or invalid video file path = \(demoPlayVideoFilePath) to play video.")
                        result(FlutterError(code: AppDelegate.errExportPlayMissingVideo,
                                            message: "Missing exported video file path to play",
                                            details: nil))
                    }
                }
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        
        // Register audio browser engine
        audioBrowserFlutterEngine.run(withEntrypoint: "audioBrowser")
        GeneratedPluginRegistrant.register(with: audioBrowserFlutterEngine)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Custom View Factory is used to provide you custom UI/UX experience in Video Editor SDK
    // i.e. custom audio browser
    func provideCustomViewFactory() -> FlutterCustomViewFactory? {
        let factory: FlutterCustomViewFactory?
        
        if (useCustomAudioBrowser) {
            factory = FlutterCustomViewFactory()
        } else {
            BanubaAudioBrowser.setMubertPat("SET MUBERT API KEY")
            factory = nil
        }
        
        return factory
    }
    
    /*
     NOT REQUIRED FOR INTEGRATION
     Added for playing exported video file.
     */
    private func demoPlayExportedVideo(controller: FlutterViewController, videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player
        
        controller.present(vc, animated: true) {
            vc.player?.play()
        }
    }
}
