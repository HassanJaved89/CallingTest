//
//  GroupChatView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/20/23.
//

import SwiftUI

struct GroupChatView: View {
    
    @State var chatGroup: ChatGroup
    @State private var shouldShowAddMembersScreen = false
    @ObservedObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        VStack {
            
            if chatGroup.participants.count <= 1 {
                emptyView
            }
            else {
                
            }
            
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shouldShowAddMembersScreen.toggle()
                } label: {
                    Image(systemName: "person.fill.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.greenColor.color)
                }

            }
        }
        .sheet(isPresented: $shouldShowAddMembersScreen, content: {
            AddMembersView(vm: CreateNewMessageViewModel(), participants: chatGroup.participants, participantsSelected: { participantsArray in
                chatGroup.participants = participantsArray
                Task {
                    try await groupsViewModel.addEditGroup(chatGroup: chatGroup)
                }
                
            })
        })
//        .fullScreenCover(isPresented: $shouldShowAddMembersScreen) {
//            AddMembersView(vm: CreateNewMessageViewModel())
//        }
        
    }
    
    private var emptyView: some View {
        VStack {
            Image("EmptyView")
                .resizable()
                .frame(width: 200, height: 150)
            
            Text("You have no memebers in the group")
                .font(.customFont(size: .medium))
                .fontWeight(.bold)
        }
        .frame(alignment: .center)
    }
}

/*
struct GroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatView()
    }
}*/
