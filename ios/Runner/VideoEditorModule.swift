import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK
import BanubaVideoEditorCore
import Flutter

// SDK 1.55.0: Banuba Video Editor API is main actor-isolated, so this module is isolated to the main actor too.
@MainActor
protocol VideoEditor {
    func initVideoEditor(token: String?, flutterResult: @escaping FlutterResult)
    
    func openVideoEditorDefault(fromViewController controller: FlutterViewController, flutterResult: @escaping FlutterResult)
        
    func openVideoEditorTrimmer(fromViewController controller: FlutterViewController, videoURL: URL, flutterResult: @escaping FlutterResult)
}

@MainActor
class VideoEditorModule: VideoEditor {

    // Not isolated, so the module can be created from a nonisolated context.
    nonisolated init() {}

    private var videoEditorSDK: BanubaVideoEditor?
    private var flutterResult: FlutterResult?
    
    // Use “true” if you want users could restore the last video editing session.
    private let restoreLastVideoEditingSession: Bool = false
    
    func initVideoEditor(
        token: String?,
        flutterResult: @escaping FlutterResult
    ) {
        guard videoEditorSDK == nil else {
            flutterResult(nil)
            return
        }
        
        var config = VideoEditorConfig()

        config.featureConfiguration.supportsTrimRecordedVideo = true

        // Make customization here
        
        videoEditorSDK = BanubaVideoEditor(
            token: token ?? "",
            // set argument .useEditorV2 to true to enable Editor V2
            arguments: [.useEditorV2 : true],
            configuration: config,
            externalViewControllerFactory: self.getAppDelegate().provideCustomViewFactory()
        )
        
        if videoEditorSDK == nil {
            flutterResult(FlutterError(code: AppDelegate.errEditorNotInitialized, message: "", details: nil))
            return
        }
        
        videoEditorSDK?.delegate = self
        flutterResult(nil)
    }
    
    func openVideoEditorDefault(
        fromViewController controller: FlutterViewController,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        let config = VideoEditorLaunchConfig(
            entryPoint: .camera,
            hostController: controller,
            animated: true
        )
        checkLicenseAndStartVideoEditor(with: config, flutterResult: flutterResult)
    }
    
    func openVideoEditorTrimmer(
        fromViewController controller: FlutterViewController,
        videoURL: URL,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult

        // Editor V2 is not available from Trimmer screen. Editor screen will be opened

        let trimmerLaunchConfig = VideoEditorLaunchConfig(
            entryPoint: .trimmer,
            hostController: controller,
            videoItems: [videoURL],
            musicTrack: nil,
            animated: true
        )
        
        checkLicenseAndStartVideoEditor(with: trimmerLaunchConfig, flutterResult: flutterResult)
    }
    
    func checkLicenseAndStartVideoEditor(with config: VideoEditorLaunchConfig, flutterResult: @escaping FlutterResult) {
        if videoEditorSDK == nil {
            flutterResult(FlutterError(code: AppDelegate.errEditorNotInitialized, message: "", details: nil))
            return
        }
        
        // Checking the license might take around 1 sec in the worst case.
        // Please optimize use if this method in your application for the best user experience
        videoEditorSDK?.getLicenseState(completion: { [weak self] isValid in
            guard let self else { return }
            if isValid {
                print("✅ The license is active")
                DispatchQueue.main.async {
                    self.videoEditorSDK?.presentVideoEditor(
                        withLaunchConfiguration: config,
                        completion: nil
                    )
                }
            } else {
                if self.restoreLastVideoEditingSession == false {
                    self.videoEditorSDK?.clearSessionData()
                }
                self.videoEditorSDK = nil
                print("❌ Use of SDK is restricted: the license is revoked or expired")
                flutterResult(FlutterError(code: "ERR_SDK_LICENSE_REVOKED", message: "", details: nil))
            }
        })
    }
    
    private func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}


// MARK: - Export flow
extension VideoEditorModule {
    func exportVideo() {
        let progressView = createProgressViewController()

        progressView.cancelHandler = { [weak self] in
            self?.videoEditorSDK?.stopExport()
        }
        
        getTopViewController()?.present(progressView, animated: true)
        
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
        
        // Set up export
        let exportConfiguration = ExportConfiguration(
            videoConfigurations: exportVideoConfigurations,
            isCoverEnabled: true,
            gifSettings: nil
        )
        
        videoEditorSDK?.export(
            using: exportConfiguration,
            exportProgress: { [weak progressView] progress in
                // The progress callback is not main actor-isolated: update the UI on the main actor.
                Task { @MainActor in progressView?.updateProgressView(with: Float(progress)) }
            }
        ) { [weak self] (error, coverImage) in
            // Export Callback
            DispatchQueue.main.async {
                progressView.dismiss(animated: true) {
                    // if export cancelled just hide progress view
                    if let error, error as NSError == exportCancelledError {
                        return
                    }
                    self?.completeExport(videoUrl: firstFileURL, error: error, coverImage: coverImage?.coverImage)
                }
            }
        }
    }
    
    private func completeExport(videoUrl: URL, error: Error?, coverImage: UIImage?) {
        videoEditorSDK?.dismissVideoEditor(animated: true) {
            let success = error == nil
            if success {
                let exportedVideoFilePath = videoUrl.path
                print("Video exported successfully = \(exportedVideoFilePath))")
                
                let coverImageData = coverImage?.pngData()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss.SSS"
                
                let coverImageURL = FileManager.default.temporaryDirectory.appendingPathComponent("export_preview-\(dateFormatter.string(from: Date())).png")
                try? coverImageData?.write(to: coverImageURL)
                
                let data = [
                    AppDelegate.argExportedVideoFile: exportedVideoFilePath,
                    AppDelegate.argExportedVideoCoverPreviewPath: coverImageURL.path
                ]
                self.flutterResult?(data)
            } else {
                print("Error while exporting video = \(String(describing: error))")
                self.flutterResult?(FlutterError(code: "ERR_MISSING_EXPORT_RESULT", message: "", details: nil))
            }
            
            // Remove strong reference to video editor sdk instance
            if self.restoreLastVideoEditingSession == false {
                self.videoEditorSDK?.clearSessionData()
            }
            self.videoEditorSDK = nil
        }
    }
    
    func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }
        
        var topController = keyWindow?.rootViewController
        
        while let newTopController = topController?.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }

    func createProgressViewController() -> ProgressViewController {
      let progressViewController = ProgressViewController.makeViewController()
      progressViewController.message = "Exporting"
      return progressViewController
    }
}

// MARK: - BanubaVideoEditorSDKDelegate
extension VideoEditorModule: BanubaVideoEditorDelegate {
    func videoEditorDidCancel(_ videoEditor: BanubaVideoEditor) {
        videoEditor.dismissVideoEditor(animated: true) {
            // remove strong reference to video editor sdk instance
            if self.restoreLastVideoEditingSession == false {
                self.videoEditorSDK?.clearSessionData()
            }
            self.videoEditorSDK = nil
        }
    }
    
    func videoEditorDone(_ videoEditor: BanubaVideoEditor) {
        exportVideo()
    }
}
