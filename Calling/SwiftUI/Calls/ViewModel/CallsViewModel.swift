//
//  CallsViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/24/23.
//

import Foundation

class CallsViewModel: ObservableObject {
    
    @Published var calls: [Call] = []
    
    init() {
        calls.append(Call(id: "1", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "2", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "3", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Missed, type: .Incoming))
        calls.append(Call(id: "4", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Incoming))
        calls.append(Call(id: "5", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Incoming))
        calls.append(Call(id: "6", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "7", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Missed, type: .Incoming))
        calls.append(Call(id: "8", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
        calls.append(Call(id: "9", user: ChatUser(data: ["userName": "Hassan Javed"]), timestamp: Date(), status: .Accepted, type: .Outgoing))
    }
    
    func fetchCalls() {
        
    }
}
