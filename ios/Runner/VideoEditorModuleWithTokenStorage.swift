import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK
import BanubaTokenStorageSDK
import FirebaseDatabase

class VideoEditorModuleWithTokenStorage: VideoEditor {
  
  private var videoEditorSDK: BanubaVideoEditor?
  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .gray)
  }()
  private lazy var provider: VideoEditorTokenProvider = {
    let firebaseTokenProvider = FirebaseTokenProvider(
      targetURL:  /*@START_MENU_TOKEN@*/"SET FIREBASE DATABASE URL"/*@END_MENU_TOKEN@*/,
      tokenSnapshot: /*@START_MENU_TOKEN@*/"SET TOKEN SNAPSHOT NAME"/*@END_MENU_TOKEN@*/
    )
    return VideoEditorTokenProvider(tokenProvider: firebaseTokenProvider)
  }()
  
  func openVideoEditor(
    fromViewController controller: FlutterViewController
  ) {
    // Load token using BanubaTokenStorage. Store token in VideoEditorSDK-Info.plist for offline mode
    fetchToken(in: controller) { [weak self] token in
      self?.presentVideoEditor(token: token, fromViewController: controller)
    }
  }
  
  private func presentVideoEditor(token: String, fromViewController controller: FlutterViewController) {
    let config = createVideoEditorConfiguration()
    videoEditorSDK = BanubaVideoEditor(
      token: token,
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
  
  private func fetchToken(in controller: UIViewController, completion: @escaping (_ token: String) -> Void) {
    controller.view.addSubview(activityIndicator)
    activityIndicator.center = controller.view.center
    activityIndicator.center.y = 150
    activityIndicator.startAnimating()
    
    provider.loadToken { [weak self] error, token in
      DispatchQueue.main.async { self?.activityIndicator.removeFromSuperview() }
      guard let token = token else { fatalError("Something wrong with fetching token from Firebase") }
      completion(token)
    }
  }
}

// MARK: - BanubaVideoEditorSDKDelegate
extension VideoEditorModuleWithTokenStorage: BanubaVideoEditorDelegate {
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

class FirebaseTokenProvider: TokenProvidable {
  let targetURL: String
  let tokenSnapshot: String
  
  init(
    targetURL: String,
    tokenSnapshot: String
  ) {
    self.targetURL = targetURL
    self.tokenSnapshot = tokenSnapshot
  }
  
  func observeToken(
    succesEvent: @escaping (String?) -> Void,
    errorEvent: @escaping (Error) -> Void
  ) {
    let database = Database.database(url: targetURL)
    let databaseReference = database.reference()
    
    databaseReference.child(tokenSnapshot).observeSingleEvent(of: .value) { dataSnapshot in
      succesEvent(dataSnapshot.value as? String)
    } withCancel: { error in
      errorEvent(error)
    }
  }
}
