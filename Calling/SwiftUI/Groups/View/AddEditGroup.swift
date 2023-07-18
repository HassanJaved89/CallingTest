//
//  AddEditGroup.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/18/23.
//

import SwiftUI

struct AddEditGroup: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State var chatGroup: ChatGroup
    @ObservedObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        NavigationView {
            
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
                        if chatGroup.imageUrl == nil || chatGroup.imageUrl == "" {
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
                            AsyncImage(url: URL(string: chatGroup.imageUrl ?? "")) {
                                returnedImage in
                                returnedImage
                                    .resizable()
                                //.scaledToFill()
                                //.font(.system(size: 60))
                                    .frame(width: 80, height: 80)
                                //.clipped()
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
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    
                }
                
                VStack {
                    TextField("Type name here", text: $chatGroup.name)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.1))
                        }
                }
                .padding()
                
                Button {
                    createGroupBtnTapped()
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
                
            }
            .navigationTitle(chatGroup.id == nil ? "Create Group" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(chatGroup.id == nil ? "Cancel" : "")
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
    }
    
    func createGroupBtnTapped() {
        
        Task {
            isLoading = true
            do {
                try await groupsViewModel.addEditGroup(chatGroup: chatGroup, selectedImage: selectedImage ?? UIImage())
            }
            
            DispatchQueue.main.async {
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

/*
struct AddEditGroup_Previews: PreviewProvider {
    static var previews: some View {
        AddEditGroup()
    }
}*/
