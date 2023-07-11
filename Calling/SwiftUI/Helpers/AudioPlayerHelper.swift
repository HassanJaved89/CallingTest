//
//  AudioPlayer.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/11/23.
//

import Foundation
import AVFoundation

class AudioPlayerHelper: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false

    func playAudio(from url: URL) {
        AudioSessionManager.shared.configureAudioSessionForPlayback()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
            } catch {
                print("Failed to play audio: \(error.localizedDescription)")
            }
        }.resume()
    }

    func stopAudio() {
        audioPlayer?.stop()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
