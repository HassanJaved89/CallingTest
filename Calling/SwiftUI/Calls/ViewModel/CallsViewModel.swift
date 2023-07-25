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
    }
    
    func fetch() {
        /*
        self.calls.removeAll()
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
    
        fireStoreListener = FirebaseManager.shared.fireStore
            .collection("Calls")
            .document(fromId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try? change.document.data(as: ChatMessage.self) {
                                var cm = cm
                                cm.timeString = cm.timestamp.convertToTime()
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
         */
    }
    
    /*
    func saveCall(call: Call) {
        
        let document = FirebaseManager.shared.fireStore.collection("Calls")
            .document(call.user.id)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use ISO8601 date format

        do {
            // Encode the Call struct to JSON data
            let jsonData = try encoder.encode(call)
            
            // Convert the JSON data to a dictionary
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                print(jsonObject)
                
                let dictionary = ["timestamp": call.timestamp, "status": call.status, "type": call.type,  "user": jsonObject] as [String : Any]
                
                document.setData(dictionary) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                }
            }
        } catch {
            print("Error encoding Call to JSON and converting to [String: Any]: \(error)")
        }
        
    }*/
}
