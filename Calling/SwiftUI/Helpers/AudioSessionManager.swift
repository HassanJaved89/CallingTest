//
//  AudioSessionManager.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/11/23.
//

import Foundation
import AVFoundation

class AudioSessionManager {
    static let shared = AudioSessionManager()

    private init() {}

    func configureAudioSessionForRecording() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session for recording: \(error.localizedDescription)")
        }
    }

    func configureAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session for playback: \(error.localizedDescription)")
        }
    }
}





