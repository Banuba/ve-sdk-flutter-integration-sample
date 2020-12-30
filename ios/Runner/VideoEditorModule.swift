import Foundation
import BanubaVideoEditorSDK

class VideoEditorModule {
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    let config = createVideoEditorConfiguration()
    let videoEditor = BanubaVideoEditor(
      token: "Place your Face AR token here",
      effectsToken: "JKUsDuoT+mERLng/LVBT/SxK7fK+1u0DuoAruXXgIJhuSI0aynki+8gGXUWAC1H3jBDYThexyDBxlvZFZ7/2nzslMbIi26y2xh4P7GI=",
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
