//
//  Group.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/18/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChatGroup: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var imageUrl: String
    var participants: [ChatUser]
}
