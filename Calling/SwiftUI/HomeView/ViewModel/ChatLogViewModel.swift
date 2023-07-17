//
//  ChatLogViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/6/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let userName = "userName"
    static let uid = "uid"
    static let profileImageUrl = "profileImageUrl"
    static let messages = "messages"
    static let users = "users"
    static let chatImageUrl = "chatImageUrl"
    static let audioUrl = "audioUrl"
}

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let chatImageUrl, audioUrl: String? 
    let timestamp: Date
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    var imageUploadUrl = ""
    var audioUrl = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 0
    var fireStoreListener: ListenerRegistration?
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        print("Chat log init")
        self.chatUser = chatUser
    }
    
    func fetch() {
        print("Fetch called")
        if self.chatUser?.uid != "" {
            fetchMessages()
        }
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.fireStore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.chatImageUrl: imageUploadUrl, FirebaseConstants.audioUrl: audioUrl, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.fireStore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
        }
    }
    
    func sendImage(image: UIImage) {
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
                        self.imageUploadUrl = downloadURL
                        self.handleSend()
                    }
                }
            }
        }
    }
    
    
    func sendAudio(recordedFileURL: URL?) {
        if let fileURL = recordedFileURL {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let filename = UUID().uuidString
            
            let fileRef = storageRef.child("recordings/\(filename).wav")

            // Start the upload
            let uploadTask = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                if let error = error {
                    // Handle the error
                    print("Error uploading file: \(error.localizedDescription)")
                    return
                }

                // Upload success
                print("File uploaded successfully")
                
                // Optionally, you can also get the download URL
                fileRef.downloadURL { url, error in
                    if let error = error {
                        // Handle the error
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url {
                        print("Download URL: \(downloadURL.absoluteString)")
                        self.audioUrl = downloadURL.absoluteString
                        self.handleSend()
                    }
                }
            }

            /*
            // Observe the upload progress
            uploadTask.observe(.progress) { snapshot in
                guard let progress = snapshot.progress else {
                    return
                }

                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                print("Upload progress: \(percentComplete)%")
            }*/
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.fireStore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.userName: chatUser.userName
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.userName: currentUser.userName
        ] as [String : Any]
        
        FirebaseManager.shared.fireStore
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    
    private func fetchMessages() {
            self.chatMessages.removeAll()
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            guard let toId = chatUser?.uid else { return }
            fireStoreListener = FirebaseManager.shared.fireStore
                .collection("messages")
                .document(fromId)
                .collection(toId)
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        if change.type == .added {
                            do {
                                if let cm = try? change.document.data(as: ChatMessage.self) {
                                    self.chatMessages.append(cm)
                                    print("Appending chatMessage in ChatLogView: \(Date())")
                                }
                            }
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.count += 1
                    }
                }
        }
    
    
    func viewScreenRemoved() {
        self.fireStoreListener?.remove()
    }
}


struct Callrequest:Codable{
    let callerName: String
    let deviceToken: String
}

extension ChatLogViewModel {
    func sendCall() {
        guard let url = URL(string: "http://114.119.185.90:3001/callingApp/Api") else {
            return
        }
        
        let caller = Callrequest(callerName: self.chatUser?.userName ?? "", deviceToken: self.chatUser?.voipDeviceToken ?? "")
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(caller)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let session = URLSession(configuration: .default, delegate: MyURLSessionDelegate(), delegateQueue: nil)
            let task = session.dataTask(with: request) { (data, response, error) in
                // Handle the API response
                if let error = error {
                    // Handle network error
                    print("Error: \(error)")
                    return
                }

                // Handle the API response data
                if let data = data {
                    // Parse the response JSON if needed
                    do {
//                        let response = try JSONDecoder().decode(Callrequest.self, from: data)
                        print(response)
                        print("Successfully sent call")
                        // Process the response object
                    } catch {
                        // Handle decoding error
                    }
                }
            }

            task.resume()
        } catch {
            // Handle encoding error
        }
    }
}


class MyURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}
