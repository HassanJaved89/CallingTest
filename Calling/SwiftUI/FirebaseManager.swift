//
//  FirebaseManager.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        
        super.init()
    }
    
    func persistImageToStore(imageData: Data, completion: @escaping (String?) -> Void) {
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
                    completion(downloadURL)
                } else {
                    // Download URL not found
                    completion(nil)
                }
            }
        }
    }
}
