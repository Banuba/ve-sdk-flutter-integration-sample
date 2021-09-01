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
    DispatchQueue.main.async {
      self.videoEditorSDK?.presentVideoEditor(
        from: controller,
        animated: true,
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
