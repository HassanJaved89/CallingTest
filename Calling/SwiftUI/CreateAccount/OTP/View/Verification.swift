//
//  Verification.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/3/23.
//

import SwiftUI

struct Verification: View {
    
    @AppStorage("isFirstTimeSignIn") private var isFirstTimeSignIn = false
    @EnvironmentObject var otpModel: AnyOTPModel
    @FocusState var activeField: OTPField?
    @State var otpFields: [String] = Array(repeating: "", count: 6)
    @State var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Image("starsImage", bundle: nil)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
            
            Text("We have sent you a code to verify your phone number")
                .multilineTextAlignment(.center)
                .font(.customFont(size: .medium))
                .fontWeight(.bold)
            
            Text("Sent to +92\(otpModel.number)")
                .font(.customFont(size: .medium))
            
            otpField()
            
            Button {
                Task {
                    isLoading = true
                    isFirstTimeSignIn = true
                    let _ = await otpModel.verifyOTP(otp: otpFields.joined())
                    isLoading = false
                }
            } label: {
                Text("Verify")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                            .fill(.blue)
//                            .opacity(isLoading ? 0 : 1)
//                    }
//                    .overlay {
//                        ProgressView()
//                            .opacity(isLoading ? 1 : 0)
//                    }
            }
            .buttonStyle(GradientButtonStyle()).opacity(isLoading ? 0.1 : 1.0)
            .overlay {
                ProgressView()
                    .foregroundColor(.white)
                    .opacity(isLoading ? 1.0 : 0)
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        self.hideKeyboard()
                    }
                }
            }
            .disabled(checkStates())
            .opacity(checkStates() ? 0.4 : 1.0)
            .padding(.vertical)
            
            VStack(spacing: 15) {
                Text("Didn't get otp?")
                    .font(.customFont(size: .medium))
                    .foregroundColor(.gray)
                
                Button("Request Again") {
                    
                }
                .font(.customFont(size: .large))
                .fontWeight(.bold)
                .foregroundColor(AppColors.greenColor.color)

            }
            .frame(maxWidth: .infinity)

        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Verification")
        .onChange(of: otpFields) { newValue in
            otpCondition(value: newValue)
        }
        .alert(otpModel.errorMsg, isPresented: $otpModel.showAlert){}
    }
    
    func checkStates() -> Bool {
        for index in 0..<6 {
            if otpFields[index].isEmpty { return true }
        }
        
        return false
    }
    
    func otpCondition(value: [String]) {
        
        for index in 0..<5 {
            if value[index].count == 1 && activeStateForIndex(index: index) == activeField {
                activeField = activeStateForIndex(index: index + 1)
            }
        }
        
        for index in 1...5 {
            if value[index].isEmpty && !value[index - 1].isEmpty {
                activeField = activeStateForIndex(index: index - 1)
            }
        }
        
        for index in 0..<6 {
            if value[index].count > 1 {
                otpFields[index] = String(value[index].last!)
            }
        }
    }
    
    @ViewBuilder
    func otpField() -> some View {
        HStack(spacing: 14) {
            ForEach(0..<6, id: \.self) { index in
                VStack(spacing: 8) {
                    TextField("", text: $otpFields[index])
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .focused($activeField, equals: activeStateForIndex(index: index))
                        .tint(AppColors.greenColor.color)
                        .frame(height: 55)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(activeField == activeStateForIndex(index: index) ? AppColors.greenColor.color : .gray.opacity(0.2), lineWidth: 2)
                        }
                    
                    /*
                    Rectangle()
                        .fill(activeField == activeStateForIndex(index: index) ? .blue : .gray.opacity(0.3))
                        .frame(height: 4)*/
                }
                .frame(height: 80)
            }
        }
    }
    
    func activeStateForIndex(index: Int) -> OTPField {
        switch index {
        case 0: return .field1
        case 1: return .field2
        case 2: return .field3
        case 3: return .field4
        case 4: return .field5
        case 5: return .field6
        default: return .field6
        }
    }
}

struct Verification_Previews: PreviewProvider {
    static var previews: some View {
        Verification()
    }
}

enum OTPField {
    case field1
    case field2
    case field3
    case field4
    case field5
    case field6
}
