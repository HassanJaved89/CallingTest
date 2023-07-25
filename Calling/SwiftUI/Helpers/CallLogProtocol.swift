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

protocol CallLogProtocol: AnyObject, ObservableObject {
    var calls: [Call] { get set }
    var fireStoreListener: ListenerRegistration? { get set }
    
    func fetch()
}
