//
//  ViewController.swift
//  AudioRecorder
//
//  Created Ashvin Gudaliya on 04/12/19.
//  Copyright © 2019 AshvinGudaliya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnPlayer: UIButton!
    
    let audioManager: AGManager = AGManager(withFileManager: AGFileManager(withFileName: nil))
    
    var isRecording: Bool = false
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioManager.delegate = self
        audioManager.checkRecordPermission()
    }

    @IBAction func redordingAction(_ sender: UIButton) {
        if !isRecording {
            isRecording = true
            self.audioManager.recordStart()
        } else {
            self.audioManager.stopRecording()
        }
    }
    
    @IBAction func playingAction(_ sender: UIButton) {
        if !isPlaying {
            isPlaying = false
            self.audioManager.startPalyer()
        } else {
            self.audioManager.stopPlaying()
        }
    }
}

extension ViewController: AGManagerDelegate {
    func recorderAndPlayer(_ manager: AGManager, withStates state: AGManagerState) {
        switch state {
        case .undetermined:
            break
        case .granted:
            btnRecord.setTitle("Initialize Recorder", for: .normal)
            btnPlayer.setTitle("Initialize Player", for: .normal)
        case .denied:
            break
            
        case .error(let erro):
            print(erro.localizedDescription)
        }
        btnRecord.isEnabled = false
        btnPlayer.isEnabled = false
    }
    
    func recorderAndPlayer(_ recoder: AGAudioRecorder, withStates state: AGRecorderState) {
        switch state {
        case .prepareToRecord:
            btnRecord.setTitle("Ready to record", for: .normal)
            btnPlayer.setTitle("Ready to Play", for: .normal)
            btnRecord.isEnabled = true
            btnPlayer.isEnabled = false
            
        case .recording:
            btnRecord.setTitle("Recording....", for: .normal)
            btnPlayer.isEnabled = false
            
        case .pause:
            btnRecord.setTitle("Pause recording", for: .normal)
            
        case .stop:
            btnRecord.setTitle("Stop recording", for: .normal)
            
        case .finish:
            btnRecord.setTitle("Recording Finish", for: .normal)
            
        case .failed(let error):
            btnRecord.setTitle(error.localizedDescription, for: .normal)
            btnPlayer.isEnabled = false
            btnRecord.isEnabled = false
        }
    }
    
    func recorderAndPlayer(_ player: AGAudioPlayer, withStates state: AGPlayerState) {
        switch state {
        case .prepareToPlay:
            btnPlayer.setTitle("Ready to Play", for: .normal)
            btnRecord.isEnabled = false
            btnPlayer.isEnabled = true
            
        case .play:
            btnPlayer.setTitle("Playing", for: .normal)
            
        case .pause:
            btnPlayer.setTitle("Pause Playing", for: .normal)
            
        case .stop:
            btnPlayer.setTitle("Stop Playing", for: .normal)
            
        case .finish:
            btnRecord.setTitle("Start New Recording", for: .normal)
            btnPlayer.setTitle("Playing Finished", for: .normal)
            btnRecord.isEnabled = true
            
        case .failed(let error):
            btnRecord.setTitle(error.localizedDescription, for: .normal)
            btnPlayer.isEnabled = false
            btnRecord.isEnabled = false
        }
    }
    
    func audioRecorderTime(currentTime timeInterval: TimeInterval, formattedString: String) {
        
    }
}
