import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK

protocol VideoEditor {
  func openVideoEditor(fromViewController controller: FlutterViewController)
}

class VideoEditorModule: VideoEditor {
  
  private var videoEditorSDK: BanubaVideoEditor?
  
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    initializeVideoEditor()
    
    DispatchQueue.main.async {
      self.startVideoEditor(from: controller)
    }
  }
  
  private func initializeVideoEditor() {
    let config = VideoEditorConfig()
    
    let viewControllerFactory = ViewControllerFactory()
    let musicEditorViewControllerFactory = MusicEditorViewControllerFactory()
    viewControllerFactory.musicEditorFactory = musicEditorViewControllerFactory
    
    videoEditorSDK = BanubaVideoEditor(
      token: /*@START_MENU_TOKEN@*/"SET BANUBA VIDEO EDITOR TOKEN"/*@END_MENU_TOKEN@*/,
      configuration: config,
      externalViewControllerFactory: viewControllerFactory
    )
    
    BanubaAudioBrowser.setMubertPat("SET MUBERT API KEY")
    
    videoEditorSDK?.delegate = self
  }
  
  private func startVideoEditor(from controller: FlutterViewController) {
    let config = VideoEditorLaunchConfig(
      entryPoint: .camera,
      hostController: controller,
      animated: true
    )
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
