//
//  AgoraRep.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/3/23.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct AgoraRep: UIViewControllerRepresentable {
    @Binding var presentationMode: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: $presentationMode)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let agoraViewController = ViewController()
        agoraViewController.presentationMode = $presentationMode
        agoraViewController.agoraDelegate = context.coordinator
        agoraViewController.dismissalHandler = {
            AppDelegate.instance.endCall()
        }
        return agoraViewController
    }
      
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  
    }
    
    class Coordinator: NSObject, AgoraRtcEngineDelegate {
        //var parent: AgoraRep
        var presentationMode: Binding<Bool>!
        
        init(presentationMode: Binding<Bool>) {
            self.presentationMode = presentationMode
        }
    }
}
