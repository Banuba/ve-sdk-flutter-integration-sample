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

class FlutterExternalViewFactory: ExternalViewControllerFactory {
  // Set nil to use BanubaAudioBrowser
  var musicEditorFactory: MusicEditorExternalViewControllerFactory? = FlutterMusicEditorExternalViewControllerFactory()
  
  var countdownTimerViewFactory: CountdownTimerViewFactory?
  
  var exposureViewFactory: AnimatableViewFactory?
}

class FlutterMusicEditorExternalViewControllerFactory: MusicEditorExternalViewControllerFactory {
  
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
