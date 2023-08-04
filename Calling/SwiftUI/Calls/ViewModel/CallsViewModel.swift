//
//  CallsViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/24/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

class CallsViewModel: ObservableObject, CallLogProtocol {
    
    @Published var calls: [Call] = []
    var fireStoreListener: ListenerRegistration?
    
    init() {
        /*
        calls.append(Call(id: "1", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "2", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "3", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Missed, type: .Incoming))
        calls.append(Call(id: "4", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Incoming))
        calls.append(Call(id: "5", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Incoming))
        calls.append(Call(id: "6", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "7", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Missed, type: .Incoming))
        calls.append(Call(id: "8", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "9", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))*/
        
        fetch()
    }
    
    func fetch() {
        
        self.calls.removeAll()
        fireStoreListener?.remove()
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
    
        fireStoreListener = FirebaseManager.shared.fireStore
            .collection("Calls")
            .document(fromId)
            .collection(fromId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try? change.document.data(as: Call.self) {
                                DispatchQueue.main.async {
                                    self.calls.insert(cm, at: 0)
                                }
                            }
                        }
                        
                    }
                })
            }
         
    }
    
    func sendCall(call: Call) {
        Task {
            let chatLogViewModel = ChatLogViewModel(chatParticipants: [call.user])
            await chatLogViewModel.sendCall()
        }
    }
}
