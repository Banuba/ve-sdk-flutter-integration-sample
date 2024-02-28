import UIKit
import Flutter
import AVKit
import BanubaAudioBrowserSDK
import BanubaPhotoEditorSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    /*
     true - uses custom audio browser implementation in this sample.
     false - to keep default implementation.
     */
    private let configEnableCustomAudioBrowser = false
    
    
    lazy var audioBrowserFlutterEngine = FlutterEngine(name: "audioBrowserEngine")
    
    // Video Editor Methods
    static let methodInitVideoEditor = "initVideoEditor"
    static let methodStartVideoEditor = "startVideoEditor"
    static let methodStartVideoEditorPIP = "startVideoEditorPIP"
    static let methodStartVideoEditorTrimmer = "startVideoEditorTrimmer"
    static let methodDemoPlayExportedVideo = "playExportedVideo"
    
    static let argExportedVideoFile = "argExportedVideoFilePath"
    static let argExportedVideoCoverPreviewPath = "argExportedVideoCoverPreviewPath"
    
    // Photo Editor Methods
    static let methodStartPhotoEditor = "startPhotoEditor"
    static let argExportedPhotoFile = "argExportedPhotoFilePath"
    
    static let errEditorNotInitialized = "ERR_SDK_NOT_INITIALIZED"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let videoEditor = VideoEditorModule()
        var photoEditor: PhotoEditorModule?
        
        if let controller = window?.rootViewController as? FlutterViewController,
           let binaryMessenger = controller as? FlutterBinaryMessenger {
            
            let channel = FlutterMethodChannel(
                name: "banubaSdkChannel",
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
                        print("Cannot start video editor in PIP mode: missing or invalid video!")
                        result(FlutterError(code: "ERR_START_PIP_MISSING_VIDEO", message: "", details: nil))
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
                        result(FlutterError(code: "ERR_EXPORT_PLAY_MISSING_VIDEO", message: "", details: nil))
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
                        print("Cannot start video editor in trimmer mode: missing or invalid video!")
                        result(FlutterError(code: "ERR_START_TRIMMER_MISSING_VIDEO", message: "", details: nil))
                    }
                case AppDelegate.methodStartPhotoEditor:
                    guard let token = methodCall.arguments as? String else {
                        print("Missing token")
                        return
                    }
                    photoEditor = PhotoEditorModule(token: token)
                    
                    photoEditor?.presentPhotoEditor(
                        fromViewController: controller,
                        flutterResult: result
                    )
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
            // Set your Mubert Api key here
            let mubertApiLicense = ""
            let mubertApiKey = ""
            AudioBrowserConfig.shared.musicSource = .allSources
            BanubaAudioBrowser.setMubertKeys(
                license: mubertApiLicense,
                token: mubertApiKey
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
