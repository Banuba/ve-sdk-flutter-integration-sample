import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK

class VideoEditorModule {
  
  private var videoEditorSDK: BanubaVideoEditor?
  
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    let config = createVideoEditorConfiguration()
    videoEditorSDK = BanubaVideoEditor(
      token: /*@START_MENU_TOKEN@*/"SET BANUBA VIDEO EDITOR TOKEN"/*@END_MENU_TOKEN@*/,
      configuration: config,
      externalViewControllerFactory: nil
    )

    BanubaAudioBrowser.setMubertPat("SET MUBERT API KEY")

    videoEditorSDK?.delegate = self
    DispatchQueue.main.async {
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
  
  private func createVideoEditorConfiguration() -> VideoEditorConfig {
    let config = VideoEditorConfig()
    // Do customization here
    return config
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
