//
//  Login.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/3/23.
//

import SwiftUI

struct Login: View {
    
    @StateObject var otpModel: AnyOTPModel = AnyOTPModel(FirebaseOTPService())
    
    @State var number: String = ""
    @State var code: String = ""
    @State var showAlert: Bool = false
    @State var isLoading = false
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                VStack(spacing: 8) {
                    TextField("1", text: $code)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                        .fill(code == "" ? .gray.opacity(0.4) : .blue)
                        .frame(height: 2)
                }
                .frame(width: 60)
                
                VStack(spacing: 8) {
                    TextField("56906578", text: $number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                        .fill(number == "" ? .gray.opacity(0.4) : .blue)
                        .frame(height: 2)
                }
                
            }
            .padding(.vertical)
            
            Button {
                isLoading = true
                Task {
                    let _ = await otpModel.sendOTP(code: code, number: number)
                    isLoading = false
                }
            } label: {
                Text("Verify")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.blue)
                            .opacity(isLoading ? 0 : 1)
                    }
                    .overlay {
                        ProgressView()
                            .opacity(isLoading ? 1.0 : 0)
                    }
            }
            .disabled(code == "" || number == "")
            .opacity(code == "" || number == "" ? 0.4 : 1)
        }
        .navigationTitle("Login")
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            NavigationLink(destination: Verification().environmentObject(otpModel), tag: OTPProcessState.otpSent, selection: $otpModel.state) {
            }
        }
        .alert(otpModel.errorMsg, isPresented: $otpModel.showAlert){}
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
