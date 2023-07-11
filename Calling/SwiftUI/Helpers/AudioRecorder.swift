//
//  AudioRecorder.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/11/23.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder!
    @Published var isRecording = false
    @Published var recordedFileURL: URL?
    
    func startRecording() {
        AudioSessionManager.shared.configureAudioSessionForRecording()
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")

        let settings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 320000
        ] as [String : Any]

        DispatchQueue.main.async {
            do {
                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                self.audioRecorder.delegate = self
                self.audioRecorder.record()
                
            } catch {
                self.finishRecording(success: false)
            }
        }
    }

    func stopRecording() {
        //if audioRecorder != nil && audioRecorder.isRecording {
            audioRecorder.stop()
            finishRecording(success: true)
        //}
    }

    func finishRecording(success: Bool) {
        //audioRecorder = nil
        //isRecording = false
        
        guard success else {
            recordedFileURL = nil
            return
        }

        recordedFileURL = audioRecorder.url
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
