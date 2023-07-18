//
//  Group.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/18/23.
//

import Foundation

struct ChatGroup: Codable, Identifiable {
    var id: String = ""
    var name: String
    var imageUrl: String
    var participants: [ChatUser]
}
