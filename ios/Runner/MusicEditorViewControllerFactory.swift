//
//  MusicEditorViewControllerFactory.swift
//  VideoEditorSDKSandbox
//
//  Created by Andrei Sak on 17.11.20.
//  Copyright © 2020 Banuba. All rights reserved.
//

import BanubaMusicEditorSDK
import BanubaVideoEditorSDK
import UIKit

/// Music editor view controller factory example
class MusicEditorViewControllerFactory: MusicEditorExternalViewControllerFactory {
  var audioBrowserController: TrackSelectionViewController?

  func makeTrackSelectionViewController(selectedAudioItem: AudioItem?) -> TrackSelectionViewController? {
    return nil
  }
  
  func makeEffectSelectionViewController(selectedAudioItem: AudioItem?) -> EffectSelectionViewController? {
    return nil
  }
  
  func makeRecorderCountdownAnimatableView() -> MusicEditorCountdownAnimatableView? {
    return nil
  }
}
