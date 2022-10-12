import Foundation
import BanubaVideoEditorSDK
import BanubaAudioBrowserSDK
import BanubaTokenStorageSDK
import FirebaseDatabase

class VideoEditorModuleWithTokenStorage: VideoEditor {
    
    private var videoEditorSDK: BanubaVideoEditor?
    private lazy var provider: VideoEditorTokenProvider = {
        let firebaseTokenProvider = FirebaseTokenProvider(
            targetURL:  /*@START_MENU_TOKEN@*/"SET FIREBASE DATABASE URL"/*@END_MENU_TOKEN@*/,
            tokenSnapshot: /*@START_MENU_TOKEN@*/"SET TOKEN SNAPSHOT NAME"/*@END_MENU_TOKEN@*/
        )
        return VideoEditorTokenProvider(tokenProvider: firebaseTokenProvider)
    }()
    
    func openVideoEditorDefault(
        fromViewController controller: FlutterViewController
    ) {
        // It might take some time to fetch a token. You can show progress indicator to your users.
        fetchToken { [weak self] token in
            guard let self = self else { return }
            
            self.initializeVideoEditor(token: token)
            
            DispatchQueue.main.async {
                
                let config = VideoEditorLaunchConfig(
                    entryPoint: .camera,
                    hostController: controller,
                    animated: true
                )
                
                self.startVideoEditor(from: controller, config: config)
            }
        }
    }
    
    func openVideoEditorPIP(
        fromViewController controller: FlutterViewController,
        videoURL: URL
    ) {
        // It might take some time to fetch a token. You can show progress indicator to your users.
        fetchToken { [weak self] token in
            guard let self = self else { return }
            
            self.initializeVideoEditor(token: token)
            
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
    }
    
    private func initializeVideoEditor(token: String) {
        let config = VideoEditorConfig()
        
        videoEditorSDK = BanubaVideoEditor(
            token: token,
            configuration: config,
            externalViewControllerFactory: nil
        )
        
        videoEditorSDK?.delegate = self
        
        BanubaAudioBrowser.setMubertPat("SET MUBERT API KEY")
    }
    
    
    private func startVideoEditor(from controller: FlutterViewController, config: VideoEditorLaunchConfig) {
        self.videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: config,
            completion: nil
        )
    }
    
    private func fetchToken(completion: @escaping (_ token: String) -> Void) {
        provider.loadToken { error, token in
            guard let token = token else { fatalError("Something went wrong with fetching token from Firebase") }
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
