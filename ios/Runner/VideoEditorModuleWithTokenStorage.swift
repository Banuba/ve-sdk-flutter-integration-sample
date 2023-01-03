import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK
import BanubaTokenStorageSDK
import FirebaseDatabase
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK
import VideoEditor
import VEExportSDK

class VideoEditorModuleWithTokenStorage: VideoEditor {
    
    private var videoEditorSDK: BanubaVideoEditor?
    private var flutterResult: FlutterResult?
    
    private lazy var provider: VideoEditorTokenProvider = {
        let firebaseTokenProvider = FirebaseTokenProvider(
            targetURL:  /*@START_MENU_TOKEN@*/"SET FIREBASE DATABASE URL"/*@END_MENU_TOKEN@*/,
            tokenSnapshot: /*@START_MENU_TOKEN@*/"SET TOKEN SNAPSHOT NAME"/*@END_MENU_TOKEN@*/
        )
        return VideoEditorTokenProvider(tokenProvider: firebaseTokenProvider)
    }()
    
    func openVideoEditorDefault(
        fromViewController controller: FlutterViewController,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        // It might take some time to fetch a token. You can show progress indicator to your users.
        fetchToken { [weak self] token in
            guard let self = self else { return }
            
            self.initializeVideoEditor(token: token, self.getAppDelegate().provideCustomViewFactory())
            
            DispatchQueue.main.async {
                
                let config = VideoEditorLaunchConfig(
                    entryPoint: .camera,
                    hostController: controller,
                    animated: true
                )
                
                self.startVideoEditor(from: controller, config: config)
            }
        }
    }
    
    func openVideoEditorPIP(
        fromViewController controller: FlutterViewController,
        videoURL: URL,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        // It might take some time to fetch a token. You can show progress indicator to your users.
        fetchToken { [weak self] token in
            guard let self = self else { return }
            
            self.initializeVideoEditor(token: token, self.getAppDelegate().provideCustomViewFactory())
            
            let pipLaunchConfig = VideoEditorLaunchConfig(
                entryPoint: .pip,
                hostController: controller,
                pipVideoItem: videoURL,
                musicTrack: nil,
                animated: true
            )
            
            DispatchQueue.main.async {
                self.startVideoEditor(from: controller, config: pipLaunchConfig)
            }
        }
    }
    
    func openVideoEditorTrimmer(
        fromViewController controller: FlutterViewController,
        videoURL: URL,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        // It might take some time to fetch a token. You can show progress indicator to your users.
        fetchToken { [weak self] token in
            guard let self = self else { return }
            
            self.initializeVideoEditor(token: token, self.getAppDelegate().provideCustomViewFactory())
            
            let trimmerLaunchConfig = VideoEditorLaunchConfig(
                entryPoint: .trimmer,
                hostController: controller,
                videoItems: [videoURL],
                musicTrack: nil,
                animated: true
            )
            
            DispatchQueue.main.async {
                self.startVideoEditor(from: controller, config: trimmerLaunchConfig)
            }
        }
    }
    
    private func initializeVideoEditor(token: String, _ viewFactory: FlutterCustomViewFactory?) {
        let config = VideoEditorConfig()
        
        videoEditorSDK = BanubaVideoEditor(
            token: token,
            configuration: config,
            externalViewControllerFactory: viewFactory
        )
        
        videoEditorSDK?.delegate = self
    }
    
    private func startVideoEditor(from controller: FlutterViewController, config: VideoEditorLaunchConfig) {
        self.videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: config,
            completion: nil
        )
    }
    
    private func fetchToken(completion: @escaping (_ token: String) -> Void) {
        provider.loadToken { error, token in
            guard let token = token else { fatalError("Something went wrong with fetching token from Firebase") }
            completion(token)
        }
    }
    
    private func getAppDelegate() -> AppDelegate {
        return  UIApplication.shared.delegate as! AppDelegate
    }
}

// MARK: - Export flow
extension VideoEditorModuleWithTokenStorage {
    func exportVideo() {
        let manager = FileManager.default
        // File name
        let firstFileURL = manager.temporaryDirectory.appendingPathComponent("banuba_demo_ve.mov")
        if manager.fileExists(atPath: firstFileURL.path) {
            try? manager.removeItem(at: firstFileURL)
        }
        
        // Video configuration
        let exportVideoConfigurations: [ExportVideoConfiguration] = [
            ExportVideoConfiguration(
                fileURL: firstFileURL,
                quality: .auto,
                useHEVCCodecIfPossible: true,
                watermarkConfiguration: nil
            )
        ]
        
        // Export Configuration
        let exportConfiguration = ExportConfiguration(
            videoConfigurations: exportVideoConfigurations,
            isCoverEnabled: true,
            gifSettings: nil
        )
        
        // Export func
        videoEditorSDK?.export(
            using: exportConfiguration,
            exportProgress: nil
        ) { [weak self] (success, error, coverImage) in
            // Export Callback
            DispatchQueue.main.async {
                if success {
                    let exportedVideoFilePath = firstFileURL.absoluteString
                    print("Export video completed successfully. Video: \(exportedVideoFilePath))")
                    
                    let data = [AppDelegate.argExportedVideoFile: exportedVideoFilePath]
                    self?.flutterResult?(data)
                    
                    // Remove strong reference to video editor sdk instance
                    self?.videoEditorSDK = nil
                } else {
                    print("Export video completed with error: \(String(describing: error))")
                    self?.flutterResult?(FlutterError(code: AppDelegate.errMissingExportResult,
                                                      message: "Export video completed with error: \(String(describing: error))",
                                                      details: nil))
                    
                    // Remove strong reference to video editor sdk instance
                    self?.videoEditorSDK = nil
                }
            }
        }
    }
}


// MARK: - BanubaVideoEditorSDKDelegate
extension VideoEditorModuleWithTokenStorage: BanubaVideoEditorDelegate {
    func videoEditorDidCancel(_ videoEditor: BanubaVideoEditor) {
        videoEditor.dismissVideoEditor(animated: true) {
            // remove strong reference to video editor sdk instance
            self.videoEditorSDK = nil
        }
    }
    
    func videoEditorDone(_ videoEditor: BanubaVideoEditor) {
        videoEditor.dismissVideoEditor(animated: true) { [weak self] in
            self?.exportVideo()
        }
    }
}

class FirebaseTokenProvider: TokenProvidable {
    let targetURL: String
    let tokenSnapshot: String
    
    init(
        targetURL: String,
        tokenSnapshot: String
    ) {
        self.targetURL = targetURL
        self.tokenSnapshot = tokenSnapshot
    }
    
    func observeToken(
        succesEvent: @escaping (String?) -> Void,
        errorEvent: @escaping (Error) -> Void
    ) {
        let database = Database.database(url: targetURL)
        let databaseReference = database.reference()
        
        databaseReference.child(tokenSnapshot).observeSingleEvent(of: .value) { dataSnapshot in
            succesEvent(dataSnapshot.value as? String)
        } withCancel: { error in
            errorEvent(error)
        }
    }
}
