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
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let agoraViewController = ViewController()
        agoraViewController.agoraDelegate = context.coordinator
        return agoraViewController
    }
      
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  
    }
    
    class Coordinator: NSObject, AgoraRtcEngineDelegate {
        var parent: AgoraRep
        
        init(_ agoraRep: AgoraRep) {
            parent = agoraRep
        }
    }
}
