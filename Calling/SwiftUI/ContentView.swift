
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
                    Text("Home")
                }
            }
            else {
                Login()
            }
        }
        .onAppear {
            checkUserState()
        }
    }
    
    func checkUserState() {
        /*
        do {
            try Auth.auth().signOut()
        }
        catch {
            
        }*/
        
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
