//
//  CallingApp.swift
//  Calling
//
//  Created by Tekrowe Digital on 6/27/23.
//

import SwiftUI
import FirebaseCore
import PushKit
import CallKit

class AppDelegate: NSObject, UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {
    
    static private(set) var instance: AppDelegate! = nil
    var pushRegistry: PKPushRegistry!
    var voipDeviceToken: String = ""
    var activeCallUUid = UUID()
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppDelegate.instance = self
        let _ = FirebaseManager.shared
      
        // Request push notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [PKPushType.voIP]

        return true
  }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return .noData
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
           if type == .voIP {
               self.voipDeviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
               print("pushRegistry -> deviceToken :\(self.voipDeviceToken)")
               // Here, you can send the device token to your server for VoIP push notification registration
               
               /*
               // Additionally, you can also register for remote notifications to receive standard push notifications
               let notificationCenter = UNUserNotificationCenter.current()
               notificationCenter.delegate = self
               notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                   if granted {
                       DispatchQueue.main.async {
                           UIApplication.shared.registerForRemoteNotifications()
                       }
                   }
               }*/
           }
       }
    
    // Handle incoming VoIP push notifications
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if type == PKPushType.voIP {
            // Handle the incoming VoIP push notification here
            
            // Display a CallKit incoming call UI
            
            if let callerName = payload.dictionaryPayload["callerName"] as? String {
                displayIncomingCall(callerName: callerName)
            }
            
            /*
            if let aps = payload.dictionaryPayload["aps"] as? [String: Any],
               let callerName = aps["callerName"] as? String {
                displayIncomingCall(callerName: callerName)
            }*/
        }
    }
    
    // Display a CallKit incoming call UI
    func displayIncomingCall(callerName: String) {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Calling")
        providerConfiguration.supportsVideo = false
        let provider = CXProvider(configuration: providerConfiguration)
        provider.setDelegate(self, queue: DispatchQueue.main)
        
        let update = CXCallUpdate()
        update.localizedCallerName = callerName
        // Set up the call update properties, such as caller information
        
        activeCallUUid = UUID()
        
        provider.reportNewIncomingCall(with: activeCallUUid, update: update) { error in
            if error == nil {
                // Call reported successfully
            }
        }
    }
    
}


// Handle CallKit actions
extension AppDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset, e.g., end any ongoing calls
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Handle answering the incoming call
        action.fulfill()
        
        if let window = UIApplication.shared.windows.first {
            let callViewController = ViewController()
            callViewController.modalPresentationStyle = .fullScreen
            callViewController.dismissalHandler = {
                window.rootViewController?.dismiss(animated: true, completion: nil)
                self.endCall()
            }
            window.rootViewController?.present(callViewController, animated: true, completion: nil)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Handle ending the ongoing call
        action.fulfill()
    }
}


extension AppDelegate {
    func endCall() {
        let controller = CXCallController()
        let transaction = CXTransaction(action: CXEndCallAction(call: activeCallUUid))
        controller.request(transaction) { error in
            
        }
    }
}

@main
struct CallingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
