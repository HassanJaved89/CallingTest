//
//  ChatLogProtocol.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/20/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

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

struct Callrequest:Codable{
    let callerName: String
    let deviceToken: String
}

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let chatImageUrl, audioUrl: String?
    let timestamp: Date
}

class CountObserver: ObservableObject {
    @Published var count: Int = 0
}

protocol ChatLogProtocol: AnyObject, ObservableObject {
    var chatParticipants: [ChatUser] { get set }
    var chatText: String { get set }
    var imageUploadUrl: String { get set }
    var audioUrl: String { get set }
    var fireStoreListener: ListenerRegistration? { get set }
    var chatMessages: [ChatMessage] { get set }
    var errorMessage: String { get set }
    var handleCount: (() -> Void)? { get set }
    
    func fetch()
    func handleSend()
    func sendImage(image: UIImage)
    func sendAudio(recordedFileURL: URL?)
    func sendCall() async
    func viewScreenRemoved()
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

extension ChatLogProtocol {
    func sendImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                
        // Create a unique filename for the image
        let filename = UUID().uuidString
        
        // Create a Firestore reference to the desired collection
        let storageRef = Storage.storage().reference().child("images").child(filename)
        
        // Upload the image to Firestore
        storageRef.putData(imageData, metadata: nil) { [weak self] (_, error) in
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
                        self?.imageUploadUrl = downloadURL
                        self?.handleSend()
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
    
    func sendCall() async {
        guard let url = URL(string: "http://114.119.185.90:3001/callingApp/Api") else {
            return
        }
        
        let receiverDeviceToken = await FirebaseManager.shared.fetchUserWithId(uid: self.chatParticipants[0].uid ?? "")?.voipDeviceToken
        let caller = Callrequest(callerName: FirebaseManager.shared.currentUser?.userName ?? "", deviceToken: receiverDeviceToken ?? "")
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
