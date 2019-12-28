//
//  AGPlayerRecorderState.swift
//  AudioRecorder
//
//  Created Ashvin Gudaliya on 09/12/19.
//  Copyright © 2019 AshvinGudaliya. All rights reserved.
//

import UIKit

enum AGPlayerRecorderState {
    case initialize
    case readyToRecord
    case recording
    case pauseRecording
    case finishRecording
    case readyToPlay
    case play
    case pausePlayer
    case stopPlayer
    case finishPlayer
    case failed(String)
}
