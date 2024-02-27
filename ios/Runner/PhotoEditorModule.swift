//
//  PhotoEditorModule.swift
//  Runner
//
//  Created by Banuba on 9.02.24.
//

import BanubaPhotoEditorSDK

class PhotoEditorModule: BanubaPhotoEditorDelegate {
    var photoEditorSDK: BanubaPhotoEditor?
    
    private var flutterResult: FlutterResult?
    
    init(token: String) {
        let configuration = PhotoEditorConfig()
        photoEditorSDK = BanubaPhotoEditor(
            token: token,
            configuration: configuration
        )
    }
    
    func presentPhotoEditor(
        fromViewController controller: FlutterViewController,
        flutterResult: @escaping FlutterResult
    ) {
        self.flutterResult = flutterResult
        
        let launchConfig = PhotoEditorLaunchConfig(
            hostController: controller,
            entryPoint: .gallery
        )
        
        photoEditorSDK?.delegate = self
        
        photoEditorSDK?.getLicenseState(completion: { [weak self] isValid in
          guard let self else { return }
          if isValid {
            print("✅ License is active, all good")
              photoEditorSDK?.presentPhotoEditor(
                  withLaunchConfiguration: launchConfig,
                  completion: nil
              )
          } else {
            print("❌ License is either revoked or expired")
          }
        })
    }
    
    // MARK: - PhotoEditorSDKDelegate
    func photoEditorDidCancel(_ photoEditor: BanubaPhotoEditor) {
        photoEditor.dismissPhotoEditor(animated: true) { [unowned self] in
            self.flutterResult?(nil)
            self.flutterResult = nil
            self.photoEditorSDK = nil
        }
    }

    func photoEditorDidFinishWithImage(_ photoEditor: BanubaPhotoEditor, image: UIImage) {
        let exportedPhotoFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
        do {
            try image.pngData()?.write(to: exportedPhotoFileUrl)
        } catch {
            debugPrint("Saving PhotoEditorSDK image failed! image path \(exportedPhotoFileUrl)")
        }
        let data = [
            AppDelegate.argExportedPhotoFile: exportedPhotoFileUrl.path,
        ]
        photoEditor.dismissPhotoEditor(animated: true) { [unowned self] in
            self.flutterResult?(data)
            self.flutterResult = nil
            self.photoEditorSDK = nil
        }
    }
}
