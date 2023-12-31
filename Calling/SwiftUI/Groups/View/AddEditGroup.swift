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
    @State private var showAddMembersView = false
    @State var chatGroup: ChatGroup
    @ObservedObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 30) {
                imageView
                
                nameField
                
                saveBtn
                
                if chatGroup.id != nil {
                    
                    addMembersBtn

                    deleteBtn
                    
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
    
    private var nameField: some View {
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
    }
    
    private var imageView: some View {
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
                    
                    ImageLoader(url: URL(string: chatGroup.imageUrl))
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
    }
    
    private var saveBtn: some View {
        Button {
            createGroupBtnTapped()
        } label: {
            HStack {
                Text("Save")
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
            }
        }
        .buttonStyle(GradientButtonStyle()).opacity(isLoading ? 0.1 : 1.0)
        .overlay {
            ProgressView()
                .foregroundColor(.white)
                .opacity(isLoading ? 1.0 : 0)
        }
    }
    
    private var addMembersBtn: some View {
        Button {
            showAddMembersView.toggle()
        } label: {
            HStack {
                Text("Add Members")
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
            }
        }
        .buttonStyle(GradientButtonStyle()).opacity(isLoading ? 0.1 : 1.0)
        .overlay {
            ProgressView()
                .foregroundColor(.white)
                .opacity(isLoading ? 1.0 : 0)
        }
        .background {
            NavigationLink("", destination: AddMembersView(vm: CreateNewMessageViewModel(), participants: [], participantsSelected: { paricicpantsArray in
                
            }), isActive: $showAddMembersView)
        }
    }
    
    private var deleteBtn: some View {
        Button {
            deleteBtnTapped()
        } label: {
            HStack {
                Text("Delete Group")
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
            }
        }
        .buttonStyle(GradientButtonStyle(startColor: AppColors.redColor.color, endColor: AppColors.redLower.color)).opacity(isLoading ? 0.1 : 1.0)
        .overlay {
            ProgressView()
                .foregroundColor(.white)
                .opacity(isLoading ? 1.0 : 0)
        }
    }
    
    func createGroupBtnTapped() {
        
        Task {
            isLoading = true
            do {
                try await groupsViewModel.addEditGroup(chatGroup: chatGroup, selectedImage: selectedImage)
            }
            
            DispatchQueue.main.async {
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func addMembersBtnTapped() {
        
    }
    
    func deleteBtnTapped() {
        
    }
}

/*
struct AddEditGroup_Previews: PreviewProvider {
    static var previews: some View {
        AddEditGroup()
    }
}*/
