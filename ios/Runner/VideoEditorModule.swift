import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK

protocol VideoEditor {
    func openVideoEditorDefault(fromViewController controller: FlutterViewController)
    
    func openVideoEditorPIP(fromViewController controller: FlutterViewController, videoURL: URL)
}

class VideoEditorModule: VideoEditor {
    
    private var videoEditorSDK: BanubaVideoEditor?
    
    func openVideoEditorDefault(
        fromViewController controller: FlutterViewController
    ) {
        initializeVideoEditor()
        
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
        videoURL: URL
    ) {
        initializeVideoEditor()
        
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
    
    private func initializeVideoEditor() {
        let config = VideoEditorConfig()
        videoEditorSDK = BanubaVideoEditor(
            token: "SET BANUBA VIDEO EDITOR SDK TOKEN",
            configuration: config,
            externalViewControllerFactory: nil
        )
        
        BanubaAudioBrowser.setMubertPat("SET MUBERT API KEY")
        
        videoEditorSDK?.delegate = self
    }
    
    private func startVideoEditor(from controller: FlutterViewController, config: VideoEditorLaunchConfig) {
        self.videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: config,
            completion: nil
        )
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
        // Do export stuff here
    }
}
