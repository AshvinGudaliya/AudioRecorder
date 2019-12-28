//
//  AGAudioPlayer.swift
//  AudioRecorder
//
//  Created Ashvin Gudaliya on 04/12/19.
//  Copyright © 2019 AshvinGudaliya. All rights reserved.
//

import UIKit
import AVFoundation

enum AGPlayerState {
    case prepareToPlay
    case play
    case pause
    case stop
    case finish
    case failed(Error)
}

class AGAudioPlayer: NSObject {

    private var player: AVAudioPlayer? = nil
    private var fileManager: AGFileManager?
    private var timer: Timer?
    
    var playerStateChangeHandler: ((AGPlayerState) -> Void)?
    
    required init(withFileManager fileManager: AGFileManager) {
        super.init()
        self.fileManager = fileManager
    }
    
    //MARK: Audio Player Functions
    func preparePlay() {
        guard let fileManager = self.fileManager else {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            self.player = try AVAudioPlayer(contentsOf: fileManager.fileUrl())
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.playerStateChangeHandler?(.prepareToPlay)
        }
        catch {
            self.playerStateChangeHandler?(.failed(error))
        }
    }
    
    func doPlay() {
        
        guard let player = player else { return }
        
        if !player.isPlaying {
            player.play()
        }
        self.scheduleTimer()
        self.playerStateChangeHandler?(.play)
    }
    
    func doPause() {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
        }
        self.timer?.invalidate()
        self.playerStateChangeHandler?(.pause)
    }
    
    func doStop() {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.stop()
        }
        self.timer?.invalidate()
        self.playerStateChangeHandler?(.stop)
    }
    
    private func scheduleTimer() {
        let fps: TimeInterval = 60
        let updateInterval = 1 / fps

        timer = Timer(timeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            guard let player = self?.player else { return }
            let progress = player.currentTime / player.duration
            print(progress)
        })

        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func cleanup() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            timer?.invalidate()
        } catch {
            playerStateChangeHandler?(.failed(error))
        }
    }
}

extension AGAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.playerStateChangeHandler?(.finish)
        }
        self.cleanup()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            self.playerStateChangeHandler?(.failed(e))
        }
        self.cleanup()
    }
}
