//
//  Call.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/24/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Call: Codable, Identifiable , Equatable {
    @DocumentID var id: String?
    let user: ChatUser
    let timestamp: Date
    let status: CallStatus
    let type: CallType
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: timestamp, to: Date())
        
        if abs(components.second ?? 0) < 10 {
            return "Now"
        }
        else {
            return formatter.localizedString(for: timestamp, relativeTo: Date())
        }
    }
}

enum CallStatus: Codable {
    case Accepted
    case Missed
    
    var description: String {
        switch self {
        case .Accepted:
            return "Accepted"
        case .Missed:
            return "Missed"
        }
    }
}

enum CallType: Codable {
    case Outgoing
    case Incoming
    
    var description: String {
        switch self {
        case .Outgoing:
            return "Outgoing"
        case .Incoming:
            return "Incoming"
        }
    }
}
