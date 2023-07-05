//
//  OTPProtocol.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/4/23.
//

import Foundation

protocol OTPProtocol {
    func sendOTP(code: String, number: String) async -> Bool
    func verifyOTP(otp: String) async -> Bool
    var state: OTPProcessState? { get set }
    var errorMsg: String { get set }
}

enum OTPProcessState {
    case success
    case failure
    case idle
    case otpSent
}
