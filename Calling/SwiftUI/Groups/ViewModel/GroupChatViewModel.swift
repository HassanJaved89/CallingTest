//
//  GroupChatViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/20/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class GroupChatViewModel: ObservableObject, ChatLogProtocol, GroupChatProtocol {
    var chatParticipants: [ChatUser]
    
    @Published var chatText: String = ""
    
    var imageUploadUrl: String = ""
    
    var audioUrl: String = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    @Published var errorMessage: String = ""
    
    var chatGroup: ChatGroup
    
    var fireStoreListener: ListenerRegistration?
    
    var handleCount: (() -> Void)?
    
    
    init(chatParticipants: [ChatUser], chatGroup: ChatGroup) {
        self.chatParticipants = chatParticipants
        self.chatGroup = chatGroup
    }
    
    func fetch() {
        self.chatMessages.removeAll()
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        fireStoreListener = FirebaseManager.shared.fireStore
            .collection("groups")
            .document(chatGroup.id ?? "")
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try? change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(cm)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.handleCount?()
                }
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let toId = ""
        
        let document = FirebaseManager.shared.fireStore.collection("groups").document(chatGroup.id ?? "").collection("messages").document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId,  FirebaseConstants.text: self.chatText, FirebaseConstants.chatImageUrl: imageUploadUrl, FirebaseConstants.audioUrl: audioUrl, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            //self.persistRecentMessage()
            
            self.chatText = ""
            self.handleCount?()
        }
    }
    
    func viewScreenRemoved() {
        self.fireStoreListener?.remove()
    }
    
}
