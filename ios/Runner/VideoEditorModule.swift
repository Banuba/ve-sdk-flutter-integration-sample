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
    
    private func initializeVideoEditor(_ externalViewControllerFactory: FlutterCustomViewFactory?) {
        let config = VideoEditorConfig()
        videoEditorSDK = BanubaVideoEditor(
            token: "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",
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
        return  UIApplication.shared.delegate as! AppDelegate
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
