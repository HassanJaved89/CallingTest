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
    
    func fetchAllGroupsWithUserId(uid: String) -> [ChatGroup] {
        groups.removeAll()
        
        groups.append(ChatGroup(id: "1", name: "Frontend", imageUrl: "", participants: []))
        groups.append(ChatGroup(id: "2", name: "Backend", imageUrl: "", participants: []))
        groups.append(ChatGroup(id: "3", name: "QA", imageUrl: "", participants: []))
        
        return groups
    }
    
    
    func addEditGroup(chatGroup: ChatGroup, selectedImage: UIImage) async {
        if chatGroup.id != "" {
            // Edit logic
        }
        else {
            // Add logic
        }
        
        return
    }
}
