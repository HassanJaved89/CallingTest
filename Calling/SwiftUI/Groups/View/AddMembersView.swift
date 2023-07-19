//
//  AddMembersView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/19/23.
//

import SwiftUI

struct AddMembersView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
            
            ScrollView {
                
                CustomSearchBar(searchText: $searchText)
                
                ForEach(vm.users.filter {
                    searchText.isEmpty || $0.userName.localizedCaseInsensitiveContains(searchText)
                } ) { user in
                    Button {
                        
                    } label: {
                        HStack(spacing: 16) {
                            
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
                                    }
                            
                            
                            Text(user.userName)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }
                .padding(.top, 5)
            }
            .padding()
            .navigationBarBackButtonHidden()
    }
}

struct AddMembersView_Previews: PreviewProvider {
    static var previews: some View {
        AddMembersView()
    }
}
