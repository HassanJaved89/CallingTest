//
//  AnyOTPModel.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/4/23.
//

import Foundation

class AnyOTPModel: OTPProtocol, ObservableObject {
    var errorMsg: String = ""
    var code = ""
    var number = ""
    
    @Published var state: OTPProcessState? = .idle
    @Published var showAlert = false
    var otpObject: OTPProtocol
    
    private let baseSendOTP: (String, String) async -> Bool
    private let baseVerifyOTP: (String) async -> Bool
    
    init<T: OTPProtocol>(_ base: T) {
        self.baseSendOTP = base.sendOTP
        self.baseVerifyOTP = base.verifyOTP
        otpObject = base
    }
    
    func sendOTP(code: String, number: String) async -> Bool {
        self.code = code
        self.number = number
        
        let result = await baseSendOTP(code, number)
        errorMsg = otpObject.errorMsg
        DispatchQueue.main.async {
            self.state = self.otpObject.state
            
            if !result {
                self.showAlert = true
            }
        }
        
        
        
        return result
    }
    
    func verifyOTP(otp: String) async -> Bool {
        let result = await baseVerifyOTP(otp)
        errorMsg = otpObject.errorMsg
        DispatchQueue.main.async {
            self.state = self.otpObject.state
            
            if !result {
                self.showAlert = true
            }
        }
        
        return result
    }
}
