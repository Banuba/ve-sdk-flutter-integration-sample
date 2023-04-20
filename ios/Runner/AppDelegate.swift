import UIKit
import Flutter
import AVKit
import BanubaAudioBrowserSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    /*
     true - uses custom audio browser implementation in this sample.
     false - to keep default implementation.
     */
    private let configEnableCustomAudioBrowser = false
    
    // Set your Mubert Api key here
    static let mubertApiLicense = ""
    static let mubertApiKey = ""
    
    lazy var audioBrowserFlutterEngine = FlutterEngine(name: "audioBrowserEngine")
    
    static let channelName = "startActivity/VideoEditorChannel"
    
    static let methodInitVideoEditor = "InitBanubaVideoEditor"
    static let methodStartVideoEditor = "StartBanubaVideoEditor"
    static let methodStartVideoEditorPIP = "StartBanubaVideoEditorPIP"
    static let methodStartVideoEditorTrimmer = "StartBanubaVideoEditorTrimmer"
    static let methodDemoPlayExportedVideo = "PlayExportedVideo"
    
    static let errMissingExportResult = "ERR_MISSING_EXPORT_RESULT"
    static let errStartPIPMissingVideo = "ERR_START_PIP_MISSING_VIDEO"
    static let errStartTrimmerMissingVideo = "ERR_START_TRIMMER_MISSING_VIDEO"
    static let errExportPlayMissingVideo = "ERR_EXPORT_PLAY_MISSING_VIDEO"
    static let errEditorNotInitialized = "ERR_VIDEO_EDITOR_NOT_INITIALIZED"
    static let errEditorLicenseRevoked = "ERR_VIDEO_EDITOR_LICENSE_REVOKED"
    
    static let argExportedVideoFile = "exportedVideoFilePath"
    static let argExportedVideoCoverPreviewPath = "exportedVideoCoverPreviewPath"
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let videoEditor = VideoEditorModule()
        
        if let controller = window?.rootViewController as? FlutterViewController,
           let binaryMessenger = controller as? FlutterBinaryMessenger {
            
            let channel = FlutterMethodChannel(
                name: AppDelegate.channelName,
                binaryMessenger: binaryMessenger
            )
            
            channel.setMethodCallHandler { methodCall, result in
                let call = methodCall.method
                switch call {
                case AppDelegate.methodInitVideoEditor:
                    let token = methodCall.arguments as? String
                    videoEditor.initVideoEditor(
                        token: token,
                        flutterResult: result
                    )
                case AppDelegate.methodStartVideoEditor:
                    videoEditor.openVideoEditorDefault(
                        fromViewController: controller,
                        flutterResult: result
                    )
                case AppDelegate.methodStartVideoEditorPIP:
                    let pipVideoFilePath = methodCall.arguments as? String
                    
                    if let videoFilePath = pipVideoFilePath {
                        videoEditor.openVideoEditorPIP(
                            fromViewController: controller,
                            videoURL: URL(fileURLWithPath: videoFilePath),
                            flutterResult: result
                        )
                    } else {
                        print("Missing or invalid video file path to start video editor in PIP mode.")
                        result(FlutterError(code: AppDelegate.errStartPIPMissingVideo,
                                            message: "Missing video to start video editor in PIP mode",
                                            details: nil))
                    }
                case AppDelegate.methodDemoPlayExportedVideo:
                    /*
                     NOT REQUIRED FOR INTEGRATION
                     Added for playing exported video file.
                     */
                    let demoPlayVideoFilePath = methodCall.arguments as? String
                    
                    if let videoFilePath = demoPlayVideoFilePath {
                        self.demoPlayExportedVideo(controller: controller, videoURL: URL(fileURLWithPath: videoFilePath))
                    } else {
                        print("Missing or invalid video file path to play video.")
                        result(FlutterError(code: AppDelegate.errExportPlayMissingVideo,
                                            message: "Missing exported video file path to play",
                                            details: nil))
                    }
                case AppDelegate.methodStartVideoEditorTrimmer:
                    let trimmerVideoFilePath = methodCall.arguments as? String
                    
                    if let videoFilePath = trimmerVideoFilePath {
                        videoEditor.openVideoEditorTrimmer(
                            fromViewController: controller,
                            videoURL: URL(fileURLWithPath: videoFilePath),
                            flutterResult: result
                        )
                    } else {
                        print("Missing or invalid video file path to start video editor in Trimmer mode.")
                        result(FlutterError(code: AppDelegate.errStartTrimmerMissingVideo,
                                            message: "Missing video to start video editor in Trimmer mode",
                                            details: nil))
                    }
                default:
                    print("Flutter method is not implemented on platform.")
                    result(FlutterMethodNotImplemented)
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
        
        if configEnableCustomAudioBrowser {
            factory = FlutterCustomViewFactory()
        } else {
            BanubaAudioBrowser.setMubertKeys(
                license: AppDelegate.mubertApiLicense,
                token: AppDelegate.mubertApiKey
            )
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
