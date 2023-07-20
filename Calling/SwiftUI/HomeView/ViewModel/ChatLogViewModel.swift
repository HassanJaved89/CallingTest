//
//  ChatLogViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/6/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class ChatLogViewModel: ObservableObject, ChatLogProtocol {
    
    var chatParticipants: [ChatUser] = [] {
        didSet {
            self.chatUserObject = chatParticipants[0]
        }
    }
    
    @Published var chatText = ""
    var imageUploadUrl = ""
    var audioUrl = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    var fireStoreListener: ListenerRegistration?
    private var chatUserObject: ChatUser?
    var handleCount: (() -> Void)?
    
    init(chatParticipants: [ChatUser]?) {
        print("Chat log init")
        self.chatUserObject = chatParticipants?[0]
    }
    
    func fetch() {
        print("Fetch called")
        if self.chatUserObject?.uid != "" {
            fetchMessages()
        }
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUserObject?.uid else { return }
        
        let document = FirebaseManager.shared.fireStore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.chatImageUrl: imageUploadUrl, FirebaseConstants.audioUrl: audioUrl, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.handleCount?()
        }
        
        let recipientMessageDocument = FirebaseManager.shared.fireStore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUserObject else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUserObject?.uid else { return }
        
        let document = FirebaseManager.shared.fireStore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.userName: chatUser.userName
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.userName: currentUser.userName
        ] as [String : Any]
        
        FirebaseManager.shared.fireStore
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
                
                self.imageUploadUrl = ""
                self.audioUrl = ""
            }
    }
    
    private func fetchMessages() {
            self.chatMessages.removeAll()
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            guard let toId = chatUserObject?.uid else { return }
            fireStoreListener = FirebaseManager.shared.fireStore
                .collection("messages")
                .document(fromId)
                .collection(toId)
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
    
    
    func viewScreenRemoved() {
        self.fireStoreListener?.remove()
    }
}
