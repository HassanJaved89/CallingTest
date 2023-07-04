//
//  OTPViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/3/23.
//

import Foundation
import SwiftUI
import Firebase

class OTPViewModel: ObservableObject {
    
    @Published var number: String = ""
    @Published var code: String = ""
    
    @Published var otpFields: [String] = Array(repeating: "", count: 6)
    
    @Published var showAlert: Bool = false
    @Published var errorMsg: String = ""
    
    @Published var verificationCode: String = ""
    @Published var isLoading = false
    
    @Published var navigationTag: String?
    
    @AppStorage("log_status") var logStatus = false
    
    func sendOtp() async {
        if isLoading { return }
        
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            let result = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(code)\(number)", uiDelegate: nil)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.verificationCode = result
                self.navigationTag = "VERIFICATION"
            }
        }
        catch {
            handleError(error: error.localizedDescription)
        }
    }
    
    func handleError(error: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMsg = error
            self.showAlert.toggle()
        }
    }
    
    func verifyOTP() async {
        do {
            DispatchQueue.main.async { [self] in
                isLoading = true
            }
            
            var otpText = ""
            for value in otpFields {
                otpText += value
            }
            
            let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationCode, verificationCode: otpText)
            let _ = try await Auth.auth().signIn(with: credentials)
            
            DispatchQueue.main.async { [self] in
                self.isLoading = false
                logStatus = true
            }
        }
        catch {
            handleError(error: error.localizedDescription)
        }
    }
}
