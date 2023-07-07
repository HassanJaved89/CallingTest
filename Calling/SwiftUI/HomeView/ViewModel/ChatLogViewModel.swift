//
//  ChatLogViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/6/23.
//

import Foundation
import Firebase
import FirebaseFirestore

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let userName = "userName"
    static let uid = "uid"
    static let profileImageUrl = "profileImageUrl"
    static let messages = "messages"
    static let users = "users"
}

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 0
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        if self.chatUser?.uid != "" {
            fetchMessages()
        }
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.fireStore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
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
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
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
            }
    }
    
    private func fetchMessages() {
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            guard let toId = chatUser?.uid else { return }
            FirebaseManager.shared.fireStore
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
                            let data = change.document.data()
                            self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.count += 1
                    }
                }
        }
}
