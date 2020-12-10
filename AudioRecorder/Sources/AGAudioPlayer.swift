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
    
    var isPlaying: Bool {
        return self.player?.isPlaying ?? false
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
        guard !player.isPlaying else { return }
    
        player.play()
        self.scheduleTimer()
        self.playerStateChangeHandler?(.play)
    }
    
    func doPause() {
        guard let player = player else { return }
        guard player.isPlaying else { return }

        player.pause()
        self.timer?.invalidate()
        self.playerStateChangeHandler?(.pause)
    }
    
    func doStop() {
        guard let player = player else { return }
        guard player.isPlaying else { return }
        
        do {
            player.stop()
            self.timer?.invalidate()
            try AVAudioSession.sharedInstance().setActive(false)
            timer?.invalidate()
            self.playerStateChangeHandler?(.stop)
        } catch {
            playerStateChangeHandler?(.failed(error))
        }
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
}

extension AGAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.playerStateChangeHandler?(.finish)
        } else {
            doStop()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            self.playerStateChangeHandler?(.failed(e))
        } else {
            doStop()
        }
    }
}
