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
    static let senderName = "senderName"
}

struct Callrequest:Codable{
    let callerName: String
    let callerId: String
    let deviceToken: [String]
    let type: CallType
    var status: CallStatus
}

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let chatImageUrl, audioUrl: String?
    let timestamp: Date
    let senderName: String?
    var timeString: String? = ""
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
    var callSent: Bool { get set }
    
    func fetch()
    func handleSend()
    func sendImage(image: UIImage, completionHandler: @escaping (String) -> Void, failureHandler: @escaping (String) -> Void)
    func sendAudio(recordedFileURL: URL?, completionHandler: @escaping (String) -> Void, failureHandler: @escaping (String) -> Void)
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
    func sendImage(image: UIImage, completionHandler: @escaping (String) -> Void, failureHandler: @escaping (String) -> Void) {
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
                failureHandler("")
            } else {
                // Image uploaded successfully
                print("Image uploaded!")
                
                // Get the download URL for the image
                storageRef.downloadURL { url, error in
                    if let error = error {
                        // Handle the download URL retrieval error
                        print("Error getting download URL: \(error.localizedDescription)")
                        failureHandler("")
                        return
                    }
                    
                    if let downloadURL = url?.absoluteString {
                       print(downloadURL)
                        completionHandler("")
                        self?.imageUploadUrl = downloadURL
                        self?.handleSend()
                    }
                }
            }
        }
    }
    
    func sendAudio(recordedFileURL: URL?, completionHandler: @escaping (String) -> Void, failureHandler: @escaping (String) -> Void) {
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
                    failureHandler("")
                    return
                }

                // Upload success
                print("File uploaded successfully")
                
                // Optionally, you can also get the download URL
                fileRef.downloadURL { url, error in
                    if let error = error {
                        // Handle the error
                        print("Error getting download URL: \(error.localizedDescription)")
                        failureHandler("")
                        return
                    }
                    
                    if let downloadURL = url {
                        print("Download URL: \(downloadURL.absoluteString)")
                        completionHandler("")
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
        
        guard let url = URL(string: "http://114.119.185.90:3004/callingApp/Api/Multiple") else {
            return
        }
        
        var deviceTokensArray: [String] = []
        var receiverUser: ChatUser?
        
        for participant in self.chatParticipants {
            if participant.uid != FirebaseManager.shared.currentUser?.uid {
                receiverUser = await FirebaseManager.shared.fetchUserWithId(uid: participant.uid)
                let receiverDeviceToken = receiverUser?.voipDeviceToken ?? ""
                deviceTokensArray.append(receiverDeviceToken)
            }
        }
        
        let caller = Callrequest(callerName: FirebaseManager.shared.currentUser?.userName ?? "", callerId: FirebaseManager.shared.currentUser?.id ?? "", deviceToken: deviceTokensArray, type: .Outgoing, status: .Accepted)
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
                        print(response)
                        print("Successfully sent call")
                        
                        let call = Call(user: receiverUser ?? ChatUser(data: [:]), timestamp: Date(), status: .Accepted, type: .Outgoing)
                        self.saveCall(call: call)
                        
                    }
                }
            }

            task.resume()
        } catch {
            // Handle encoding error
        }
    }
    
    
    func saveCall(call: Call) {
        let document = FirebaseManager.shared.fireStore.collection("Calls")
            .document(FirebaseManager.shared.currentUser?.id ?? "")
            .collection(FirebaseManager.shared.currentUser?.id ?? "")
            .document()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use ISO8601 date format

        do {
            let jsonData = try Firestore.Encoder().encode(call)
            document.setData(jsonData) { error in
                if let error = error {
                    print(error)
                    return
                }
            }
        } catch {
            print("Error encoding Call to JSON and converting to [String: Any]: \(error)")
        }
    }
}
