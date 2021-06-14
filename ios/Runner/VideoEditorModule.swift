import Foundation
import BanubaVideoEditorSDK

class VideoEditorModule {
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    let config = createVideoEditorConfiguration()
    let videoEditor = BanubaVideoEditor(
      token: "Place your Face AR token here",
      configuration: config,
      externalViewControllerFactory: nil
    )
    DispatchQueue.main.async {
      videoEditor.presentVideoEditor(
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
