//
//  VEExternalViewFactory.swift
//  Runner
//
//  Created by Andrei Sak on 7.10.22.
//

import BanubaVideoEditorSDK
import BanubaMusicEditorSDK
import BanubaUtilities
import Flutter

class FlutterCustomViewFactory: ExternalViewControllerFactory {
  // Set nil to use BanubaAudioBrowser
  var musicEditorFactory: MusicEditorExternalViewControllerFactory? = CustomAudioBrowserViewControllerFactory()
  
  var countdownTimerViewFactory: CountdownTimerViewFactory?
  
  var exposureViewFactory: AnimatableViewFactory?
}

class CustomAudioBrowserViewControllerFactory: MusicEditorExternalViewControllerFactory {
  
  // Tracks selection view controller
  func makeTrackSelectionViewController(selectedAudioItem: AudioItem?) -> TrackSelectionViewController? {
    let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).audioBrowserFlutterEngine
    
    // One instance of the FlutterEngine can only be attached to one FlutterViewController at a time.
    // Set FlutterEngine.viewController to nil before attaching it to another FlutterViewController.
    flutterEngine.viewController = nil
    
    let flutterTrackSelectionViewController = FlutterTrackSelectionViewController(
      engine: flutterEngine,
      nibName: nil,
      bundle: nil
    )
    
    flutterTrackSelectionViewController.listenFlutterCalls()
    
    return flutterTrackSelectionViewController
  }
  
  // Effects selection view controller. Used at Music editor screen
  func makeEffectSelectionViewController(selectedAudioItem: BanubaUtilities.AudioItem?) -> BanubaMusicEditorSDK.EffectSelectionViewController? {
    return nil
  }
  
  // Returns recorder countdown view for voice recorder screen
  func makeRecorderCountdownAnimatableView() -> BanubaMusicEditorSDK.MusicEditorCountdownAnimatableView? {
    return nil
  }
}

private class FlutterTrackSelectionViewController: FlutterViewController, TrackSelectionViewController {
  
  // MARK: - TrackSelectionViewController
  var trackSelectionDelegate: BanubaMusicEditorSDK.TrackSelectionViewControllerDelegate?
  
  private var channel: FlutterMethodChannel?
  
  func listenFlutterCalls() {
    channel = FlutterMethodChannel(
      name: "audioBrowserChannel",
      binaryMessenger: binaryMessenger
    )
    channel?.setMethodCallHandler { [weak self] methodCall, resultHandler in
      guard let self = self else {
        resultHandler(FlutterMethodNotImplemented)
        return
      }
      
      switch methodCall.method {
      case "trackSelected":
        self.handleTrackSelection(args: methodCall.arguments, resultHandler: resultHandler)
      case "close":
        self.trackSelectionDelegate?.trackSelectionViewControllerDidCancel(viewController: self)
        resultHandler(nil)
      case "stopUsingTrack":
        self.handleStopUsingTrack(args: methodCall.arguments, resultHandler: resultHandler)
      default: resultHandler(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func handleTrackSelection(args: Any?, resultHandler: (Any?) -> Void) {
    struct Track: Codable {
      let url: URL
      let id: Int32
      let title: String
    }
    guard let string = args as? String,
          let data = string.data(using: .utf8),
          let track = try? JSONDecoder().decode(Track.self, from: data) else {
      resultHandler(FlutterMethodNotImplemented)
      return
    }
    trackSelectionDelegate?.trackSelectionViewController(
      viewController: self,
      didSelectFile: track.url,
      isEditable: true,
      title: track.title,
      additionalTitle: nil,
      id: track.id
    )
    resultHandler(nil)
  }
  
  private func handleStopUsingTrack(args: Any?, resultHandler: (Any?) -> Void) {
    struct TrackId: Codable {
      let id: Int32
    }
    guard let string = args as? String,
          let data = string.data(using: .utf8),
          let track = try? JSONDecoder().decode(TrackId.self, from: data) else {
      resultHandler(FlutterMethodNotImplemented)
      return
    }
    trackSelectionDelegate?.trackSelectionViewController(
      viewController: self,
      didStopUsingTrackWithId: track.id
    )
    resultHandler(nil)
  }
}
