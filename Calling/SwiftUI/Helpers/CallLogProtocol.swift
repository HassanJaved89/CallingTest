//
//  CallLogProtocol.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/25/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage


// This protocol will be used for all the Calls related stuff that includes Calling, Call logs for now. This functionality is currently implemented in ChatLogProtocol but that will be extracted because it violates the Single Responsibility principle.

protocol CallLogProtocol: AnyObject, ObservableObject {
    var calls: [Call] { get set }
    var fireStoreListener: ListenerRegistration? { get set }
    
    func fetch()
}
