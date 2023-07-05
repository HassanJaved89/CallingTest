//
//  CreateAccount.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/4/23.
//

import SwiftUI

struct AccountSettings: View {
    
    @AppStorage("isFirstTimeSignIn") private var isFirstTimeSignIn = false
    @State var userName: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            Button {
                showImagePicker.toggle()
            } label: {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .cornerRadius(64)
                }
                else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .padding()
                        .background {
                            Circle()
                                .stroke(lineWidth: 2)
                        }
                }
                
            }
            
            VStack {
                TextField("Username", text: $userName)
                Rectangle().fill(Color.blue)
                    .frame(height: 1)
            }
            .padding()
            
            Button {
                createAccountTapped()
            } label: {
                HStack {
                    Text("Create")
                        .frame(maxWidth: .infinity, maxHeight: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding()
                        .overlay {
                            ProgressView()
                                .opacity(isLoading ? 1.0 : 0)
                        }
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .padding(.vertical, 50)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
    }
    
    func createAccountTapped() {
        isLoading = true
        
        FirebaseManager.shared.persisUserDataToStore(imageData: (selectedImage?.jpegData(compressionQuality: 0.8))!, userName: userName) { success in
            isFirstTimeSignIn = false
            isLoading = false
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings()
    }
}
