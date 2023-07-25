//
//  AccountSettingsViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/17/23.
//

import Foundation

class AccountSettingsViewModel: ObservableObject {
    
    @Published var user: ChatUser?
    @Published var errorMessage = ""
    
    init() {
        //fetchAllUsers()
    }
    

    func fetchAllUsers() async -> Bool {
        do {
            let documentsSnapshot = try await FirebaseManager.shared.fireStore.collection("users").getDocuments()
            
            for snapshot in documentsSnapshot.documents {
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid == FirebaseManager.shared.auth.currentUser?.uid {
                    DispatchQueue.main.async {
                        self.user = .init(data: data)
                    }
                    
                    return true
                }
            }
        } catch {
            self.errorMessage = "Failed to fetch users: \(error)"
            print("Failed to fetch users: \(error)")
            return false
        }
        
        return false
    }
    
}
