
import SwiftUI
import AgoraUIKit

struct ContentView: View {
    
    @AppStorage("log_status") var logStatus = false
    
    var body: some View {
        NavigationView {
            if logStatus {
                Text("Home")
            }
            else {
                Login()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
