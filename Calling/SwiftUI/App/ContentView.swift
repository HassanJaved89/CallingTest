
import SwiftUI
import AgoraUIKit
import Firebase

struct ContentView: View {
    
    @State private var isUserSignedIn = false
    @AppStorage("isFirstTimeSignIn") private var isFirstTimeSignIn = false
    
    var body: some View {
        NavigationView {
            
            if isUserSignedIn {
                if isFirstTimeSignIn {
                    AccountSettings()
                }
                else {
                    //MainMessagesView(chatUser: ChatUser(data: ["" : ""]))
                    HomeViewTab()
                }
            }
            else {
                GetStarted()
            }
        }
        .onAppear {
            checkUserState()
        }
    }
    
    func checkUserState() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("User is already signed in with ID: \(user.uid)")
                isUserSignedIn = true
            } else {
                print("User is signed out")
                isUserSignedIn = false
            }
        }
    }
    
    func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
        }
        catch {
            
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
