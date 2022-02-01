import Foundation
import BanubaVideoEditorSDK

class VideoEditorModule {
  
  private var videoEditorSDK: BanubaVideoEditor?
  
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    let config = createVideoEditorConfiguration()
    videoEditorSDK = BanubaVideoEditor(
      token: "Place your VideoEditorSDK token here",
      configuration: config,
      externalViewControllerFactory: nil
    )
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
