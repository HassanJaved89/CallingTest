//
//  CreateNewMessageView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import SwiftUI

struct CreateNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    var didSelectNewChatUser: (ChatUser) -> ()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                ForEach(vm.users.filter {
                    searchText.isEmpty || $0.userName.localizedCaseInsensitiveContains(searchText)
                } ) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewChatUser(user)
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
                            
                            Text(user.userName)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                        .frame(minHeight: 60)
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }
            }.navigationTitle("Contacts")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
        .searchable(text: $searchText)
    }
}
