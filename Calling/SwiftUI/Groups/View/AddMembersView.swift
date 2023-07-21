//
//  AddMembersView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/19/23.
//

import SwiftUI

struct AddMembersView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: CreateNewMessageViewModel
    @State var participants: [ChatUser]
    @State private var searchText = ""
    var participantsSelected: ([ChatUser]) -> Void
    
    var body: some View {
        
        ScrollView {
            
            CustomSearchBar(searchText: $searchText)
            
            membersList
            
            Spacer()

        }
        .padding()
        .navigationBarBackButtonHidden()
        
        Button {
            participantsSelected(participants)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
            .foregroundColor(.white)
            .padding(.vertical, 12)
        }
        .padding()
        .buttonStyle(GradientButtonStyle())
    }
    
    
    private var membersList: some View {
        ForEach(vm.users.filter {
            searchText.isEmpty || $0.userName.localizedCaseInsensitiveContains(searchText)
        } ) { user in
            Button {
                
            } label: {
                HStack(spacing: 16) {
                    
                    ImageLoader(url: URL(string: user.profileImageUrl))
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(50)
                        .overlay(RoundedRectangle(cornerRadius: 50)
                            .stroke(Color(.label), lineWidth: 2)
                        )
                    
                    
                    
                    /*
                    AsyncImage(url: URL(string: user.profileImageUrl )) { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 50)
                                .stroke(Color(.label), lineWidth: 2)
                            )
                    } placeholder: {
                        ProgressView()
                    }*/
                    
                    
                    Text(user.userName)
                        .foregroundColor(Color(.label))
                    
                    Spacer()
                    
                    Button {
                        toggleUserSelection(user)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                            if participants.contains(user) {
                                Image("CheckMark")
                            }
                        }
                    }

                }
                .frame(minHeight: 50)
                .padding(.horizontal)
            }
            Divider()
                .padding(.vertical, 8)
            
        }
        .padding(.top, 5)
    }
    
    private func toggleUserSelection(_ user: ChatUser) {
        if participants.contains(user) {
            participants.removeAll { $0 == user }
        } else {
            participants.append(user)
        }
    }

    
}

/*
struct AddMembersView_Previews: PreviewProvider {
    static var previews: some View {
        AddMembersView()
    }
}*/
