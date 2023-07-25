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
    var fireStoreListener: ListenerRegistration?
    var userDidSet: (() -> Void)?
    
    var currentUser: ChatUser? {
        didSet {
            userDidSet?()
        }
    }
    
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
    
    func fetchUserWithId(uid: String)async  -> ChatUser? {
        do {
            let documentsSnapshot = try await FirebaseManager.shared.fireStore.collection("users").getDocuments()
            
            for snapshot in documentsSnapshot.documents {
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid == uid {
                    return ChatUser(data: data)
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    
    func listenForUserChanges() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        fireStoreListener?.remove()
        
        fireStoreListener = FirebaseManager.shared.fireStore
            .collection("users")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .modified {
                        do {
                            if let cm = try? change.document.data(as: ChatUser.self) {
                                var cm = cm
                                if cm.id == FirebaseManager.shared.currentUser?.id {
                                    FirebaseManager.shared.currentUser = cm
                                }
                            }
                        }
                    }
                })
            }
    }
    
    func logout() {
        do {
            try FirebaseManager.shared.auth.signOut()
        }
        catch {
            
        }
    }
}


//MARK: - Groups
extension FirebaseManager {
    
    func uploadGroupImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                
        // Create a unique filename for the image
        let filename = UUID().uuidString
        
        // Create a Firestore reference to the desired collection
        let storageRef = Storage.storage().reference().child("images").child(filename)
        
        // Upload the image to Firestore
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                // Handle the upload error
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                // Image uploaded successfully
                print("Image uploaded!")
                
                // Get the download URL for the image
                storageRef.downloadURL { url, error in
                    if let error = error {
                        // Handle the download URL retrieval error
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url?.absoluteString {
                       print(downloadURL)
                        completion(downloadURL)
                    }
                }
            }
        }
    }
    
}
