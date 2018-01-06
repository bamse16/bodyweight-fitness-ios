//
//  AudioManager.swift
//  BodyweightFitness
//
//  Created by Marius Ursache on 6/1/18.
//  Copyright © 2018 Damian Mazurkiewicz. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer?

    override init() {
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
    }

    func playFinished() {
        let alertSound = URL(fileURLWithPath: Bundle.main .path(forResource: "finished", ofType: "mp3")!)

        do {
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: alertSound, fileTypeHint: nil)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("AVAudioSession errors.")
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with:
                AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession errors.")
        }
    }
}
