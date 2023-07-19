//
//  GroupsViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/18/23.
//

import Foundation
import UIKit

class GroupsViewModel: ObservableObject {
    @Published var groups: [ChatGroup] = []
    
    init() {
        
    }
    
    
    func addEditGroup(chatGroup: ChatGroup, selectedImage: UIImage) async throws {
        var chatGroup = chatGroup
        
        let imageURL = try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<String?, Error>) in
            FirebaseManager.shared.uploadGroupImage(image: selectedImage) { url in
                continuation.resume(returning: url)
            }
        }
        
        chatGroup.imageUrl = imageURL ?? ""
        
        let participantsData: [[String: Any]] = try chatGroup.participants.map { try JSONSerialization.jsonObject(with: try JSONEncoder().encode($0)) as? [String: Any] ?? [:] }
        
        let dictionary = ["name": chatGroup.name, "imageUrl": chatGroup.imageUrl, "participants": participantsData] as [String : Any]
        
        do {
            _ = try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<ChatGroup?, Error>) in
                
                if chatGroup.id != nil {
                    FirebaseManager.shared.fireStore.collection("groups")
                        .document(chatGroup.id ?? "").setData(dictionary) { err in
                            if let error = err {
                                print("Error editing group: \(error)")
                                continuation.resume(throwing: error)
                            } else {
                                print("Group edited successfully")
                                continuation.resume(returning: chatGroup)
                            }
                    }
                }
                else {
                    FirebaseManager.shared.fireStore.collection("groups").addDocument(data: dictionary) { error in
                        if let error = error {
                            print("Error creating group: \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            print("Group created successfully")
                            continuation.resume(returning: chatGroup)
                        }
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchGroups() {
        self.groups.removeAll()
        
        FirebaseManager.shared.fireStore.collection("groups").addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching groups: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                let docId = change.document.documentID
                
                if let index = self.groups.firstIndex(where: { rm in
                    return rm.id == docId
                }) {
                    self.groups.remove(at: index)
                }
                
                do {
                    if let rm = try? change.document.data(as: ChatGroup.self) {
                        self.groups.append(rm)
                    }
                }
            })
        }
    }
}
