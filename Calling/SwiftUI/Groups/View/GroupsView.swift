//
//  GroupsView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/18/23.
//

import SwiftUI

struct GroupsView: View {
    
    @State private var searchText = ""
    @State var shouldShowNewGroupScreen = false
    @State var shouldNavigationToGroupView = false
    @ObservedObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        VStack {
            CustomSearchBar(searchText: $searchText)
            groupsView
        }
        .padding(.top, 25)
        .overlay(
            addNewGroupButton, alignment: .bottomTrailing)
        .padding(.horizontal)
        .onAppear {
            groupsViewModel.fetchGroups()
        }
    }
    
    private var groupsView: some View {
        ScrollView {
            ForEach(groupsViewModel.groups.filter {
                searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
            } ) { group in
                VStack {
                    NavigationLink {
                        //AddEditGroup(chatGroup: group, groupsViewModel: groupsViewModel)
                        GroupChatView(chatGroup: group, groupsViewModel: groupsViewModel)
                    } label: {
                        HStack(spacing: 16) {
                            if group.imageUrl == "" {
                                Image(systemName: "rectangle.3.group.bubble.left")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                            }
                            else {
                                AsyncImage(url: URL(string: group.imageUrl)) { returnedImage in
                                                    returnedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipped()
                                        .cornerRadius(40)
                                        .overlay(RoundedRectangle(cornerRadius: 40)
                                                    .stroke(Color.black, lineWidth: 1))
                                        .shadow(radius: 5)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.name)
                                    .font(.customFont(size: .medium))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.label))
                                    .multilineTextAlignment(.leading)
                                Text("\(group.participants.count) participants")
                                    .font(.customFont(size: .small))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
        .padding(.top, 20)
    }
    
    private var addNewGroupButton: some View {
        Button {
            shouldShowNewGroupScreen = true
        } label: {
            Image("AddBtn")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 64, maxHeight: 64)
                .clipped()
        }
        .fullScreenCover(isPresented: $shouldShowNewGroupScreen) {
            AddEditGroup(chatGroup: ChatGroup(name: "", imageUrl: "", participants: [FirebaseManager.shared.currentUser!]), groupsViewModel: groupsViewModel)
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView(groupsViewModel: GroupsViewModel())
    }
}
