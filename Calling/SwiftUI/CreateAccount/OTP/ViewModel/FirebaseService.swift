//
//  OTPViewModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/3/23.
//

import Foundation
import SwiftUI
import Firebase

class FirebaseOTPService: OTPProtocol {
    
    var errorMsg: String = ""
    private var verificationCode = ""
    var state: OTPProcessState? = .idle
    
    func sendOTP(code: String, number: String) async -> Bool {
        
        state = .idle
        
        do {
            let result = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(code)\(number)", uiDelegate: nil)
            state = .otpSent
            
            DispatchQueue.main.async {
                self.verificationCode = result
            }
            
            return true
        }
        catch {
            handleError(error: error.localizedDescription)
        }
        
        return false
    }
    
    func handleError(error: String) {
        DispatchQueue.main.async {
            self.errorMsg = error
            self.state = .failure
        }
    }
    
    func verifyOTP(otp: String) async -> Bool {
        do {
            
            let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationCode, verificationCode: otp)
            let _ = try await Auth.auth().signIn(with: credentials)
            state = .success
            return true
            
        }
        catch {
            handleError(error: error.localizedDescription)
        }
        
        return false
    }
}
