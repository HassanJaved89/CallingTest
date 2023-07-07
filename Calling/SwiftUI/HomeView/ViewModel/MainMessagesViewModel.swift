//
//  MainMessagesViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import Foundation
import FirebaseFirestore

struct ChatUser: Identifiable {
    var id:String { uid }
    
    let uid, userName, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}

struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, userName: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [RecentMessage]()
    
    init() {
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    private func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        
        FirebaseManager.shared.fireStore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
//            self.errorMessage = "123"
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
                
            }
            
            self.chatUser = ChatUser(data: data)
            
        }
    }
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.fireStore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                    
                    
//                    self.recentMessages.append()
                })
            }
    }
    
    func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
        }
        catch {
            
        }
    }
    
}
