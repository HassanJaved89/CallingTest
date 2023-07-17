//
//  FirebaseManager.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let fireStore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
        
        super.init()
    }
    
    func persisUserDataToStore(imageData: Data, userName: String, completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        // Create a unique filename for the image
        let fileName = "\(UUID().uuidString).jpg"
        
        let storageRef = self.storage.reference(withPath: userId).child(fileName)
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                // Handle the upload error
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Get the download URL for the image
            storageRef.downloadURL { url, error in
                if let error = error {
                    // Handle the download URL retrieval error
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    // Image uploaded successfully
                    let userData = ["userName": userName, "uid": userId, "profileImageUrl": downloadURL, "voipDeviceToken": AppDelegate.instance.voipDeviceToken]
                    FirebaseManager.shared.fireStore.collection("users")
                        .document(userId).setData(userData) { err in
                            if let err = err {
                                print(err)
                                return
                            }
                        }
                    
                    completion(downloadURL)
                } else {
                    // Download URL not found
                    completion(nil)
                }
            }
        }
    }
    
}
