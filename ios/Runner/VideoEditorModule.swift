import Foundation
import BanubaVideoEditorSDK
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK
import BanubaAudioBrowserSDK
import VideoEditor
import VEExportSDK
import Flutter

protocol VideoEditor {
    func openVideoEditorDefault(fromViewController controller: FlutterViewController, flutterResult: @escaping FlutterResult)
    
    func openVideoEditorPIP(fromViewController controller: FlutterViewController, videoURL: URL, flutterResult: @escaping FlutterResult)
    
    func openVideoEditorTrimmer(fromViewController controller: FlutterViewController, videoURL: URL, flutterResult: @escaping FlutterResult)
}

class VideoEditorModule: VideoEditor {
    
    private var videoEditorSDK: BanubaVideoEditor?
    private var flutterResult: FlutterResult?
    
    func openVideoEditorDefault(
        fromViewController controller: FlutterViewController,
        flutterResult : @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        initializeVideoEditor(getAppDelegate().provideCustomViewFactory())
        
        let config = VideoEditorLaunchConfig(
            entryPoint: .camera,
            hostController: controller,
            animated: true
        )
        
        DispatchQueue.main.async {
            self.startVideoEditor(from: controller, config: config)
        }
    }
    
    func openVideoEditorPIP(
        fromViewController controller: FlutterViewController,
        videoURL: URL,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        initializeVideoEditor(getAppDelegate().provideCustomViewFactory())
        
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
    
    func openVideoEditorTrimmer(
        fromViewController controller: FlutterViewController,
        videoURL: URL,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        initializeVideoEditor(getAppDelegate().provideCustomViewFactory())
        
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
    
    private func initializeVideoEditor(_ externalViewControllerFactory: FlutterCustomViewFactory?) {
        let config = VideoEditorConfig()
        videoEditorSDK = BanubaVideoEditor(
            token: AppDelegate.licenseToken,
            configuration: config,
            externalViewControllerFactory: externalViewControllerFactory
        )
        
        videoEditorSDK?.delegate = self
    }
    
    private func startVideoEditor(from controller: FlutterViewController, config: VideoEditorLaunchConfig) {
        self.videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: config,
            completion: nil
        )
    }
    
    private func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}


// MARK: - Export flow
extension VideoEditorModule {
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
extension VideoEditorModule: BanubaVideoEditorDelegate {
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
