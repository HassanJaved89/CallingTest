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
    @State var code: String = "92"
    @State var showAlert: Bool = false
    @State var isLoading = false
    
    var body: some View {
        VStack {
            Image("MinistryImage", bundle: nil)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            VStack {
                Text("MINISTRY OF INFORMATION AND BROADCASTING")
                Divider()
                Text("Government of Pakistan")
            }
            .foregroundColor(.black)
            .font(.customFont(size: .small))
            
            Text("Sign in to your Account")
                .font(.customFont(size: .large))
                .fontWeight(.bold)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 30) {
                VStack(spacing: 8) {
                    Text("Phone Number")
                        .font(.customFont(size: .medium))
                    
                    /* Use this for phone number country code
                    TextField("1", text: $code)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                        .fill(code == "" ? .gray.opacity(0.4) : .blue)
                        .frame(height: 2)*/
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("+92")
                            //.frame(width: 50, height: 50)
                            .padding()
                            .font(.customFont(size: .medium))
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        TextField("", text: $number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            
                    }
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.1))
                    }
                    
                    /*
                    Rectangle()
                        .fill(number == "" ? .gray.opacity(0.4) : .blue)
                        .frame(height: 2)*/
                }
                
            }
            .padding(.top, 30)
            
            Button {
                isLoading = true
                Task {
                    if number.hasPrefix("0") {
                        number = String(number.dropFirst())
                    }
                    let _ = await otpModel.sendOTP(code: code, number: number)
                    isLoading = false
                }
            } label: {
                Text("Sign in")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
//                    .background {
//
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                            .fill(.blue)
//                            .opacity(isLoading ? 0 : 1)
//                    }
//                    .overlay {
//                        ProgressView()
//                            .opacity(isLoading ? 1.0 : 0)
//                    }
            }
            .buttonStyle(GradientButtonStyle()).opacity(isLoading ? 0.1 : 1.0)
            .overlay {
                ProgressView()
                    .foregroundColor(.white)
                    .opacity(isLoading ? 1.0 : 0)
            }
            .padding(.top, 20)
            .disabled(code == "" || number == "")
            .opacity(code == "" || number == "" ? 0.4 : 1)
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    self.hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
        .padding()
        .padding(.top, 70)
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
