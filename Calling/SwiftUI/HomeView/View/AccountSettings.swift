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
    @ObservedObject var accountSettingsVm: AccountSettingsViewModel
    
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
                    if accountSettingsVm.user?.profileImageUrl == nil || accountSettingsVm.user?.profileImageUrl == "" {
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .tint(AppColors.greenColor.color)
                            .padding()
                            .background {
                                Circle()
                                    .fill(.gray.opacity(0.2))
    //                                .stroke(lineWidth: 2)
                                    .tint(AppColors.greenColor.color)
                            }
                            .overlay(alignment: .bottomTrailing) {
                                Button {
                                    showImagePicker.toggle()
                                } label: {
                                    Image("imageUpload")
                                        .frame(width: 35, height: 35 ,alignment: .bottom)
                                }

                            }
                    }
                    else {
                        
                        ImageLoader(url: URL(string: accountSettingsVm.user?.profileImageUrl ?? ""))
                            .frame(width: 80, height: 80)
                            .cornerRadius(40)
                            .overlay(alignment: .bottomTrailing) {
                                Button {
                                    showImagePicker.toggle()
                                } label: {
                                    Image("imageUpload")
                                        .frame(width: 35, height: 35 ,alignment: .bottom)
                                }

                            }
                            .shadow(radius: 5)
                        
                    }
                }
                
            }
            
            VStack {
                TextField("Type name here", text: $userName)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.1))
                    }
            }
            .padding()
            
            Button {
                createAccountTapped()
            } label: {
                HStack {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
//                        .overlay {
//                            ProgressView()
//                                .opacity(isLoading ? 1.0 : 0)
//                        }
                }
            }
            .buttonStyle(GradientButtonStyle()).opacity(isLoading ? 0.1 : 1.0)
            .overlay {
                ProgressView()
                    .foregroundColor(.white)
                    .opacity(isLoading ? 1.0 : 0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    self.hideKeyboard()
                }
            }
        }
        .onAppear {
            Task {
                let _ = await accountSettingsVm.fetchAllUsers()
                userName = accountSettingsVm.user?.userName ?? ""
            }
        }
        .navigationTitle("Profile")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .padding(.vertical, 50)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
    }
    
    func createAccountTapped() {
        isLoading = true
        
        FirebaseManager.shared.persisUserDataToStore(imageData: (selectedImage?.jpegData(compressionQuality: 0.8) ?? UIImage(systemName: "person.fill")?.jpegData(compressionQuality: 0.8))!, userName: userName) { success in
            isFirstTimeSignIn = false
            isLoading = false
        }
    }
}

/*
struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings()
    }
}*/
